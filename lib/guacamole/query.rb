# -*- encoding : utf-8 -*-

module Guacamole
  # Build a query for ArangoDB
  class Query
    include Enumerable

    # Connection to the database
    #
    # @return [Ashikawa::Core::Collection]
    attr_reader :connection

    # The mapper class
    #
    # @return [Class]
    attr_reader :mapper

    # The example to search for
    #
    # @return [Hash] the example
    attr_accessor :example

    # Currently set options
    #
    # @return [Hash]
    # @api private
    attr_accessor :options

    # Create a new Query
    #
    # @param [Ashikawa::Core::Collection] connection The collection to use to talk to the database
    # @param [Class] mapper the class of the mapper to use
    def initialize(connection, mapper)
      @connection = connection
      @mapper = mapper
      @options = {}
    end

    # Iterate over the result of the query
    #
    # This will execute the query you have build
    def each
      return to_enum(__callee__) unless block_given?

      iterator = ->(document) { yield mapper.document_to_model(document) }

      if example
        connection.by_example(example, options).each(&iterator)
      else
        connection.all(options).each(&iterator)
      end
    end

    # Limit the results of the query
    #
    # @param [Fixnum] limit
    # @return [self]
    def limit(limit)
      options[:limit] = limit
      self
    end

    # The number of results to skip
    #
    # @param [Fixnum] skip
    # @return [self]
    def skip(skip)
      options[:skip] = skip
      self
    end
  end
end
