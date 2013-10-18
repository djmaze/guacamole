# -*- encoding : utf-8 -*-

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fabrication'
require 'ashikawa-core'

begin
  require 'debugger'
rescue LoadError
  puts "Debugger is not available. Maybe you're Travis."
end

class Fabrication::Generator::Guacamole < Fabrication::Generator::Base

  def self.supports?(klass)
    defined?(Guacamole) && klass.ancestors.include?(Guacamole::Model)
  end

  def persist
    collection = [_instance.class.name.pluralize, 'Collection'].join.constantize
    collection.save _instance
  end

  def validate_instance
    _instance.valid?
  end

end

Fabrication::Schematic::Definition::GENERATORS.unshift Fabrication::Generator::Guacamole

module Guacamole
  class Configuration
    attr_accessor :database, :default_mapper
  end

  class << self
    def configure(&block)
      @configuration = Configuration.new
      block.call @configuration

      @configuration
    end

    def configuration
      @configuration
    end
  end
end

# FIXME: This is copied from Ashikawa::Core for now but is not recommended. This
# setup uses the default database instead of a custom DB. Due to this we're deleting
# all collections in the default database each time we run the specs.
# => This is not good!
port = ENV['ARANGODB_PORT'] || 8529
username = ENV['ARANGODB_USERNAME'] || 'root'
password = ENV['ARANGODB_PASSWORD'] || ''

Guacamole.configure do |config|
  config.database = Ashikawa::Core::Database.new { |arango_config|
    arango_config.url = "http://localhost:#{port}"
    unless ENV['ARANGODB_DISABLE_AUTHENTIFICATION']
      arango_config.username = username
      arango_config.password = password
    end
  }

  config.default_mapper = Guacamole::DocumentModelMapper
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Guacamole.configuration.database.collections.each { |collection| collection.truncate! }
  end
end
