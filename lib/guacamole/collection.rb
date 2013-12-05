# -*- encoding : utf-8 -*-

require 'guacamole/query'

require 'ashikawa-core'
require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

module Guacamole
  # A collection persists and offers querying for models
  #
  # You use this as a mixin in your collection classes. Per convention,
  # they are the plural form of your model with the suffix `Collection`.
  # For example the collection of `Blogpost` models would be `BlogpostsCollection`.
  # Including `Guacamole::Collection` will add a number of class methods to
  # the collection. See the `ClassMethods` submodule for details
  module Collection
    extend ActiveSupport::Concern

    # The class methods added to the class via the mixin
    #
    # @!method model_to_document(model)
    #   Convert a model to a document to save it to the database
    #
    #   You can use this method for your hand made storage or update methods.
    #   Most of the time it makes more sense to call save or replace though,
    #   they do the conversion and handle the communication with the database
    #
    #   @param [Model] model The model to be converted
    #   @return [Ashikawa::Core::Document] The converted document
    module ClassMethods
      extend Forwardable
      def_delegators :mapper, :model_to_document
      def_delegator :connection, :fetch, :fetch_document

      attr_accessor :connection, :mapper, :database

      # The raw `Database` object that was configured
      #
      # You can use this method for low level communication with the database.
      # Details can be found in the Ashikawa::Core documentation.
      #
      # @see http://rubydoc.info/gems/ashikawa-core/Ashikawa/Core/Database
      # @return [Ashikawa::Core::Database]
      def database
        @database ||= Guacamole.configuration.database
      end

      # The raw `Collection` object for this collection
      #
      # You can use this method for low level communication with the collection.
      # Details can be found in the Ashikawa::Core documentation.
      #
      # @see http://rubydoc.info/gems/ashikawa-core/Ashikawa/Core/Collection
      # @return [Ashikawa::Core::Collection]
      def connection
        @connection ||= database[collection_name]
      end

      # The DocumentModelMapper for this collection
      #
      # @api private
      # @return [DocumentModelMapper]
      def mapper
        @mapper ||= Guacamole.configuration.default_mapper.new(model_class)
      end

      # The name of the collection in ArangoDB
      #
      # Use this method in your hand crafted AQL queries, for debugging etc.
      #
      # @return [String] The name
      def collection_name
        @collection_name ||= name.gsub(/Collection\z/, '').underscore
      end

      # The class of the resulting models
      #
      # @return [Class] The model class
      def model_class
        @model_class ||= collection_name.singularize.camelcase.constantize
      end

      # Find a model by its key
      #
      # The key is the unique identifier of a document within a collection,
      # this concept is similar to the concept of IDs in most databases.
      #
      # @param [String] key
      # @return [Model] The model with the given key
      # @example Find a podcast by its key
      #   podcast = PodcastsCollection.by_key('27214247')
      def by_key(key)
        raise Ashikawa::Core::DocumentNotFoundException unless key

        mapper.document_to_model connection.fetch(key)
      end

      # Persist a model in the collection or replace it in the database, depending if it is already persisted
      #
      # * If {Model#persisted? model#persisted?} is `false`, the model will be saved in the collection. Timestamps, revision
      #   and key will be set on the model.
      # * If {Model#persisted? model#persisted?} is `true`, it replaces the currently saved version of the model with
      #   its new version. It searches for the entry in the database
      #   by key. This will change the updated_at timestamp and revision
      #   of the provided model.
      #
      # See also {#create create} and {#replace replace} for explicit usage.
      #
      # @param [Model] model The model to be saved
      # @return [Model] The provided model
      # @example Save a podcast to the database
      #   podcast = Podcast.new(title: 'Best Show', guest: 'Dirk Breuer')
      #   PodcastsCollection.save(podcast)
      #   podcast.key #=> '27214247'
      # @example Get a podcast, update its title, replace it
      #   podcast = PodcastsCollection.by_key('27214247')
      #   podcast.title = 'Even better'
      #   PodcastsCollection.save(podcast)
      def save(model)
        model.persisted? ? replace(model) : create(model)
      end

      # Persist a model in the collection
      #
      # The model will be saved in the collection. Timestamps, revision
      # and key will be set on the model.
      #
      # @param [Model] model The model to be saved
      # @return [Model] The provided model
      # @example Save a podcast to the database
      #   podcast = Podcast.new(title: 'Best Show', guest: 'Dirk Breuer')
      #   PodcastsCollection.save(podcast)
      #   podcast.key #=> '27214247'
      def create(model)
        return false unless model.valid?

        add_timestamps_to_model(model)
        create_document_from(model)
        model
      end

      # Delete a model from the database
      #
      # @param [String, Model] model_or_key The key of the model or a model
      # @return [String] The key
      # @example Delete a podcast by key
      #   PodcastsCollection.delete(podcast.key)
      # @example Delete a podcast by model
      #   PodcastsCollection.delete(podcast)
      def delete(model_or_key)
        key = if model_or_key.respond_to? :key
          model_or_key.key
        else
          model_or_key
        end
        fetch_document(key).delete
        key
      end

      # Replace a model in the database with its new version
      #
      # Replaces the currently saved version of the model with
      # its new version. It searches for the entry in the database
      # by key. This will change the updated_at timestamp and revision
      # of the provided model.
      #
      # @param [Model] model The model to be replaced
      # @return [Model] The model
      # @example Get a podcast, update its title, replace it
      #   podcast = PodcastsCollection.by_key('27214247')
      #   podcast.title = 'Even better'
      #   PodcastsCollection.replace(podcast)
      def replace(model)
        return false unless model.valid?

        model.updated_at = Time.now
        replace_document_from(model)
        model
      end

      # Find models by the provided attributes
      #
      # Search for models in the collection where the attributes are equal
      # to those that you provided.
      # This returns a Query object, where you can provide additional information
      # like limiting the results. See the documentation of Query or the examples
      # for more information.
      # All methods of the Enumerable module and `.to_a` will lead to the execution
      # of the query.
      #
      # @param [Hash] example The attributes and their values
      # @return [Query]
      # @example Get all podcasts with the title 'Best Podcast'
      #   podcasts = PodcastsCollection.by_example(title: 'Best Podcast').to_a
      # @example Get the second batch of podcasts for batches of 10 with the title 'Best Podcast'
      #   podcasts = PodcastsCollection.by_example(title: 'Best Podcast').skip(10).limit(10).to_a
      # @example Iterate over all podcasts with the title 'Best Podcasts'
      #   PodcastsCollection.by_example(title: 'Best Podcast').each do |podcast|
      #     p podcast
      #   end
      def by_example(example)
        query = all
        query.example = example
        query
      end

      # Get all Models stored in the collection
      #
      # The result can be limited (and should be for most datasets)
      # This can be done one the returned Query object.
      # All methods of the Enumerable module and `.to_a` will lead to the execution
      # of the query.
      #
      # @return [Query]
      # @example Get all podcasts
      #   podcasts = PodcastsCollection.all.to_a
      # @example Get the first 50 podcasts
      #   podcasts = PodcastsCollection.all.limit(50).to_a
      def all
        Query.new(connection.query, mapper)
      end

      # Specify details on the mapping
      #
      # The method is called with a block where you can specify
      # details about the way that the data from the database
      # is mapped to models.
      #
      # See `DocumentModelMapper` for details on how to configure
      # the mapper.
      def map(&block)
        mapper.instance_eval(&block)
      end

      # Timestamp a fresh model
      #
      # @api private
      def add_timestamps_to_model(model)
        timestamp = Time.now
        model.created_at = timestamp
        model.updated_at = timestamp
      end

      # Create a document from a model
      #
      # @api private
      def create_document_from(model)
        document = connection.create_document(model_to_document(model))

        model.key = document.key
        model.rev = document.revision

        document
      end

      # Replace a document in the database with this model
      #
      # @api private
      def replace_document_from(model)
        document = model_to_document(model)
        response = connection.replace(model.key, document)

        model.rev = response['_rev']

        document
      end

    end
  end
end
