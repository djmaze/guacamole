# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/collection'

class TestCollection
  include Guacamole::Collection
end

describe Guacamole::Collection do

  class FakeMapper
    def document_to_model(document)
      document
    end
  end

  subject { TestCollection }

  let(:connection) { double('Connection') }
  let(:mapper)     { FakeMapper.new }

  it 'should provide a method to get mapped documents by key from the database' do
    subject.connection = connection
    subject.mapper     = mapper
    document           = { data: 'foo' }

    expect(connection).to receive(:fetch).with('some_key').and_return(document)
    expect(mapper).to receive(:document_to_model).with(document).and_call_original

    model = subject.by_key 'some_key'
    expect(model[:data]).to eq 'foo'
  end

end
