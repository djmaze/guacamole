# -*- encoding : utf-8 -*-
require 'active_support/concern'
# Cherry Pick not possible
require 'active_model'
require 'virtus'

module Guacamole
  # A domain model of your application
  #
  # A Guacamole::Model represents a single entry in your collection or an embedded entry
  # of another entry.
  # You use this as a Mixin in your model classes.
  #
  # @note This is not a model according to the active record pattern. It does not know anything about the database.
  #
  # @!attribute [r] key
  #   Key of the document in the collection
  #
  #   The key identifies a document distinctly within one collection.
  #
  #   @return [String] The key of the document
  #   @note Only set when persisted
  #
  # @!attribute [r] rev
  #   The revision of the document
  #
  #   ArangoDB keeps changes the revision of a document automatically, when it has changed.
  #   With this functionality you can quickly find out if you have the most recent version
  #   of the document.
  #
  #   @return [String] The revision of the document
  #   @note Only set when persisted
  #
  # @!attribute [r] created_at
  #   Timestamp of the creation of this document
  #
  #   This will automatically be set when the document was first saved to the database.
  #
  #   @return [Time] Timestamp of the creation of the model in the database
  #   @note Only set when persisted
  #
  # @!attribute [r] updated_at
  #   Timestamp of the last update of this document
  #
  #   This will automatically be changed whenever the document is saved.
  #
  #   @return [Time] Timestamp of the last update in the database
  #   @note Only set when persisted
  #
  # @!method self.attribute(attribute_name, type)
  #   Define an attribute for this model (Provided by Virtus)
  #
  #   @note Setting the value of an attribute leads to automatic coercion
  #   @param attribute_name [Symbol] The name of the attribute to define
  #   @param type [Class] The type of the attribute
  #   @see https://github.com/solnic/virtus
  #   @api public
  #   @example Define an attribute of type String
  #     class BlogPost
  #       include Guacamole::Model
  #
  #       attribute :title, String
  #     end
  #
  #   @example Define an attribute containing an array of Strings
  #     class Repository
  #       include Guacamole::Model
  #
  #       attribute :contributor_names, Array[String]
  #     end
  #
  # @!method self.validates
  #   This method is a shortcut to all default validators and any custom validator classes ending in 'Validator'
  #
  #   For further details see the documentation of ActiveModel
  #   or the RailsGuide on Validations
  #
  #   @see http://guides.rubyonrails.org/active_record_validations.html
  #   @api public
  #   @example Validate the presence of the name
  #     class Person
  #       include Guacamole::Model
  #
  #       attribute :name, String
  #       validates :name, presence: true
  #     end
  #
  # @!method self.validate
  #   Adds a validation method or block to the class
  #
  #   For further details see the documentation of ActiveModel
  #   or the RailsGuide on Validations
  #
  #   @see http://guides.rubyonrails.org/active_record_validations.html
  #   @api public
  #   @example Validate that the person is awesome
  #     class Person
  #       include Guacamole::Model
  #       validate :is_awesome
  #
  #       def is_awesome
  #         # Check if the person is awesome
  #       end
  #     end
  #
  # @!method self.validates_with
  #   Passes the record off to the class or classes specified
  #
  #   This and allows to add errors based on more complex conditions
  #
  #   For further details see the documentation of ActiveModel
  #   or the RailsGuide on Validations
  #
  #   @see http://guides.rubyonrails.org/active_record_validations.html
  #   @api public
  #   @example Validate that the person is awesome
  #     class Person
  #       include Guacamole::Model
  #       validates_with PersonValidator
  #     end
  #
  #     class PersonValidator < ActiveModel::Validator
  #       def validate(record)
  #         # check if the person is valid
  #       end
  #     end
  #
  # @!method persisted?
  #   Checks if the object is persisted
  #
  #   @return [Boolean]
  #   @api public
  #
  # @!method valid?
  #   Runs all the specified validations and returns true if no errors were added otherwise false
  #
  #   For further details see the documentation of ActiveModel
  #   or the RailsGuide on Validations
  #
  #   @see http://guides.rubyonrails.org/active_record_validations.html
  #   @api public
  #
  # @!method invalid?
  #   Performs the opposite of `valid?`. Returns true if errors were added, false otherwise
  #
  #   For further details see the documentation of ActiveModel
  #   or the RailsGuide on Validations
  #
  #   @see http://guides.rubyonrails.org/active_record_validations.html
  #   @api public
  #
  # @!method errors
  #   Returns the Errors object that holds all information about attribute error messages
  #
  #   For further details see the documentation of ActiveModel
  #   or the RailsGuide on Validations
  #
  #   @see http://guides.rubyonrails.org/active_record_validations.html
  #   @api public
  #
  # @!method ==(other)
  #   Check if the attributes are from the same model class and have equal attributes
  #
  #   @param [Model] other the model to compare with
  #   @api public
  module Model
    extend ActiveSupport::Concern
    # @!parse include ActiveModel::Validations
    # @!parse extend ActiveModel::Naming
    # @!parse include ActiveModel::Conversion
    # I know that this is technically not true, but the reality is a parse error:
    # @!parse include Virtus

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
          attributes.all? do |attribute, value|
            other_value = other.send(attribute)
            case value
            when DateTime, Time
              value.to_s == other_value.to_s # :(
            else
              value == other_value
            end
          end
      end
      alias_method :eql?, :==

    end
  end
end
