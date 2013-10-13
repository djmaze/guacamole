# -*- encoding : utf-8 -*-
require 'active_support/concern'
require 'virtus'

module Guacamole
  module Model
    extend ActiveSupport::Concern

    included do
      include Virtus.model

      attribute :key, String
      attribute :rev, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end
  end
end
