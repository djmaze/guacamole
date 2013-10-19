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
      if example
        connection.by_example(example).each do |document|
          yield mapper.document_to_model(document)
        end
      else
        connection.all.each do |document|
          yield mapper.document_to_model(document)
        end
      end
    end
  end
end
