# -*- encoding : utf-8 -*-

module Guacamole
  # This is the default mapper class to map between Ashikawa::Core::Document and
  # Guacamole::Model instances.
  class DocumentModelMapper
    attr_reader :model_class
    attr_reader :models_to_embed

    def initialize(model_class)
      @model_class = model_class
      @models_to_embed = []
    end

    def document_to_model(document)
      model = model_class.new(document.hash)

      model.key = document.key
      model.rev = document.revision

      model
    end

    def model_to_document(model)
      document = model.attributes.dup.except(:key, :rev)
      models_to_embed.each do |attribute_name|
        document[attribute_name] = model.send(attribute_name).map do |embedded_model|
          embedded_model.attributes.except(:key, :rev)
        end
      end
      document
    end

    def embeds(model_name)
      @models_to_embed << model_name
    end
  end
end
