# -*- encoding : utf-8 -*-
require 'guacamole'

describe 'Basics' do

  class Article
    include Guacamole::Model

    attribute :title, String
  end

  describe Article do
    it 'should allow setting its title' do
      pending 'To be implemented'
      subject.title = 'This is my fancy article'

      expect(subject.title).to eq('This is my fancy article')
    end

    it 'should have key and rev attributes' do
      pending 'To be implemented'
      expect(subject.key).to be_nil
      expect(subject.rev).to be_nil
    end

    it 'should have timestamp attributes which are empty' do
      pending 'To be implemented'
      expect(subject.created_at).to be_nil
      expect(subject.updated_at).to be_nil
    end
  end
end
