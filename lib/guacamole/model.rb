# -*- encoding : utf-8 -*-
require 'active_support/concern'
# Cherry Pick not possible
require 'active_model'
require 'virtus'

module Guacamole
  module Model
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations
      include ActiveModel::Naming
      include ActiveModel::Conversion
      include Virtus.model

      attribute :key, String
      attribute :rev, String
      attribute :created_at, Time
      attribute :updated_at, Time

      def persisted?
        key.present?
      end

      # For ActiveModel::Conversion compliance only, please use key
      def id
        key
      end

      def ==(other)
        other.instance_of?(self.class) &&
          key.present? &&
          other.key == key &&
          rev.present? &&
          other.rev == rev
      end
      alias_method :eql?, :==

    end
  end
end
