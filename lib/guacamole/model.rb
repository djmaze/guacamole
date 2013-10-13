# -*- encoding : utf-8 -*-
require 'active_support/concern'
require 'virtus'

module Guacamole
  module Model
    extend ActiveSupport::Concern

    included do
      include Virtus.model
    end
  end
end
