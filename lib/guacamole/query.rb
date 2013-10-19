# -*- encoding : utf-8 -*-

module Guacamole
  # Build a query for ArangoDB
  class Query
    attr_reader :connection
    attr_reader :mapper
    attr_accessor :example

    def initialize(connection, mapper)
      @connection = connection
      @mapper = mapper
    end

    def each
      return to_enum(__callee__) unless block_given?

      iterator = ->(document) { yield mapper.document_to_model(document) }

      if example
        connection.by_example(example).each(&iterator)
      else
        connection.all.each(&iterator)
      end
    end
  end
end
