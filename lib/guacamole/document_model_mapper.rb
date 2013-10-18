# -*- encoding : utf-8 -*-

module Guacamole
  # This is the default mapper class to map between Ashikawa::Core::Document and
  # Guacamole::Model instances.
  class DocumentModelMapper
    attr_reader :model_class

    def initialize(model_class)
      @model_class = model_class
    end

    def document_to_model(document)
      model = model_class.new(document.hash)

      model.key = document.key
      model.rev = document.revision

      model
    end

    def model_to_document(model)
      model.attributes.dup.except(:key, :rev)
    end

  end
end
