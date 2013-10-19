# -*- encoding : utf-8 -*-

require 'logger'

require 'guacamole/document_model_mapper'

module Guacamole

  class << self
    def configure(&config_block)
      config_block.call configuration

      configuration
    end

    def configuration
      @configuration ||= Configuration
    end
  end

  # This class holds the configuration for Guacamole.
  class Configuration
    attr_accessor :database, :default_mapper, :logger

    class << self
      def database=(database)
        configuration.database = database
      end

      def database
        configuration.database
      end

      def default_mapper=(default_mapper)
        configuration.default_mapper = default_mapper
      end

      def default_mapper
        configuration.default_mapper || (self.default_mapper = Guacamole::DocumentModelMapper)
      end

      def logger=(logger)
        configuration.logger = logger
      end

      def logger
        configuration.logger ||= default_logger
      end

      private

      def configuration
        @configuration ||= new
      end

      def default_logger
        default_logger       = Logger.new(STDOUT)
        default_logger.level = Logger::INFO
        default_logger
      end
    end
  end
end
