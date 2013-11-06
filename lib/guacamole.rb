# -*- encoding : utf-8 -*-

require 'active_support/core_ext'

require 'guacamole/version'
require 'guacamole/configuration'
require 'guacamole/model'
require 'guacamole/collection'
require 'guacamole/document_model_mapper'

if defined?(Rails)
  require 'guacamole/railtie'
end

# An ODM for ArangoDB
#
# For more general information, see README or Homepage
module Guacamole
end
