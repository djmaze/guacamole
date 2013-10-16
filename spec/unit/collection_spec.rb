# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/collection'

class TestCollection
  include Guacamole::Collection
end

describe Guacamole::Collection do

  subject { TestCollection }

  describe 'Configuration' do
    it 'should set the connection to ArangoDB' do
      mock_db_connection = double('ConnectionToCollection')
      subject.connection = mock_db_connection

      expect(subject.connection).to eq mock_db_connection
    end

    it 'should set the Mapper instance to map documents to models and vice versa' do
      mock_mapper    = double('Mapper')
      subject.mapper = mock_mapper

      expect(subject.mapper).to eq mock_mapper
    end
  end

  let(:connection) { double('Connection') }
  let(:mapper)     { double('Mapper') }

  it 'should provide a method to get mapped documents by key from the database' do
    subject.connection = connection
    subject.mapper     = mapper
    document           = { data: 'foo' }
    model              = double('Model')

    expect(connection).to receive(:fetch).with('some_key').and_return(document)
    expect(mapper).to receive(:document_to_model).with(document).and_return(model)

    expect(subject.by_key('some_key')).to eq model
  end

end
