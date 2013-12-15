# -*- encoding : utf-8 -*-

require 'logger'
require 'forwardable'
require 'ashikawa-core'
require 'active_support/core_ext'

require 'guacamole/document_model_mapper'

module Guacamole
  class << self
    # Configure Guacamole
    #
    # Takes a block in which you can configure Guacamole.
    # @return [Configuration] the resulting configuration
    def configure(&config_block)
      config_block.call configuration

      configuration
    end

    # Contains the configuration of Guacamole
    #
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration
    end
  end

  # Current configuration
  #
  # You can receive the configuration by calling Guacamole.configuration
  #
  # @!attribute self.database
  #   The raw Database object
  #
  #   The Database implementation is part of Ashikawa::Core
  #
  #   @see http://rubydoc.info/gems/ashikawa-core/Ashikawa/Core/Database
  #   @return [Ashikawa::Core::Database]
  #
  # @!attribute self.default_mapper
  #   The Mapper class that is used by default. This defaults to
  #   DocumentModelMapper
  #
  #   @return [Class] the default mapper class
  #
  # @!attribute self.logger
  #   The logger
  #
  #   This defaults to the Rails logger
  #
  #   @return [Object] the logger
  #
  # @!attribute [r] self.current_environment
  #   The current environment Guacamole is running in
  #
  #   If you are running in Rails, this will return the current Rails environment
  #
  #   @return [Object] current environment
  class Configuration
    # @!visibility protected
    attr_accessor :database, :default_mapper, :logger

    class << self
      extend Forwardable

      def_delegators :configuration, :database, :database=, :default_mapper=, :logger=

      def default_mapper
        configuration.default_mapper || (self.default_mapper = Guacamole::DocumentModelMapper)
      end

      def logger
        configuration.logger ||= (rails_logger || default_logger)
      end

      # Load a YAML configuration file to configure Guacamole
      #
      # @param [String] file_name The file name of the configuration
      def load(file_name)
        config = YAML.load_file(file_name)[current_environment.to_s]

        self.database = create_database_connection_from(config)
      end

      def current_environment
        return Rails.env if defined?(Rails)
        ENV['RACK_ENV'] || ENV['GUACAMOLE_ENV']
      end

      private

      def configuration
        @configuration ||= new
      end

      def create_database_connection_from(config)
        Ashikawa::Core::Database.new do |arango_config|
          arango_config.url      = db_url_from(config)
          arango_config.username = config['username']
          arango_config.password = config['password']
          arango_config.logger   = logger
        end
      end

      def db_url_from(config)
        "#{config['protocol']}://#{config['host']}:#{config['port']}/_db/#{config['database']}"
      end

      def rails_logger
        return Rails.logger if defined?(Rails)
      end

      def default_logger
        default_logger       = Logger.new(STDOUT)
        default_logger.level = Logger::INFO
        default_logger
      end
    end
  end
end
