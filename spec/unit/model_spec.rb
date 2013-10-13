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

  describe 'default attributes' do
    subject { TestModel.new }

    it 'should add the key attribute' do
      subject.key = '12345'
      expect(subject.key).to eq '12345'
    end

    it 'should add the rev attribute' do
      subject.rev = '98765'
      expect(subject.rev).to eq '98765'
    end
  end
end
