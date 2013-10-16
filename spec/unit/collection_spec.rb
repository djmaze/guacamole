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

  describe 'save' do

    before do
      subject.connection = connection
      subject.mapper     = mapper

      allow(connection).to receive(:create_document).with(document).and_return(document)
      allow(mapper).to receive(:model_to_document).with(model).and_return(document)
    end

    let(:key)       { double('Key') }
    let(:rev)       { double('Rev') }
    let(:document)  { double('Document', key: key, revision: rev).as_null_object }
    let(:model)     { double('Model').as_null_object }

    context 'a valid model' do
      it 'should create a document' do
        expect(connection).to receive(:create_document).with(document).and_return(document)
        expect(mapper).to receive(:model_to_document).with(model).and_return(document)

        subject.save model
      end

      it 'should return the model after calling save' do
        expect(subject.save(model)).to eq model
      end

      it 'should set timestamps before creating the document' do
        now = double('DateTime.now')

        allow(DateTime).to receive(:now).once.and_return(now)

        expect(model).to receive(:created_at=).with(now).ordered
        expect(model).to receive(:updated_at=).with(now).ordered

        allow(connection).to receive(:create_document).with(document).and_return(document).ordered

        subject.save model
      end

      it 'should add key to model' do
        expect(model).to receive(:key=).with(key)

        subject.save model
      end

      it 'should add rev to model' do
        expect(model).to receive(:rev=).with(rev)

        subject.save model
      end
    end

    context 'an invalid model' do

      before do
        expect(model).to receive(:valid?).and_return(false)
      end

      it 'should not create the document' do
        expect(connection).to receive(:create_document).never

        subject.save model
      end

      it 'should not change the model' do
        expect(model).to receive(:created_at=).never
        expect(model).to receive(:updated_at=).never
        expect(model).to receive(:key=).never
        expect(model).to receive(:rev=).never

        subject.save model
      end
    end

  end
end
