# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/model'

class TestModel
  include Guacamole::Model
end

describe Guacamole::Model do
  subject { TestModel }

  describe 'module inclusion' do
    it 'should include Virtus.model' do
      expect(subject.ancestors.any? do |ancestor|
        ancestor.to_s.include? 'Virtus'
      end).to be_true
    end
  end
end
