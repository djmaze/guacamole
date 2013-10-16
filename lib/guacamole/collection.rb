# -*- encoding : utf-8 -*-
require 'active_support/concern'

module Guacamole
  module Collection
    extend ActiveSupport::Concern

    module ClassMethods

      attr_accessor :connection, :mapper

      def by_key(key)
        mapper.document_to_model connection.fetch(key)
      end

      def save(model)
        timestamp = DateTime.now
        model.created_at = timestamp
        model.updated_at = timestamp
        document = connection.create_document(mapper.model_to_document(model))
        model.key = document.key
        model.rev = document.revision
      end

    end

  end
end
