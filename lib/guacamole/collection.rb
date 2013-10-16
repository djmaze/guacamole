# -*- encoding : utf-8 -*-
require 'active_support/concern'

module Guacamole
  module Collection
    extend ActiveSupport::Concern

    module ClassMethods
      extend Forwardable
      def_delegators :mapper, :model_to_document
      def_delegator :connection, :fetch, :fetch_document

      attr_accessor :connection, :mapper

      def by_key(key)
        mapper.document_to_model connection.fetch(key)
      end

      def save(model)
        return model unless model.valid?

        add_timestamps_to_model model
        create_document_from model
        model
      end

      def delete(key)
        fetch_document(key).delete
        key
      end

      def replace(model)
        model.updated_at = DateTime.now
        document = model_to_document(model)
        connection.replace(model.key, document)
        model.rev = document['_rev']
        model
      end

      def add_timestamps_to_model(model)
        timestamp = DateTime.now
        model.created_at = timestamp
        model.updated_at = timestamp
      end

      def create_document_from(model)
        document = connection.create_document(model_to_document(model))

        model.key = document.key
        model.rev = document.revision

        document
      end

    end

  end
end
