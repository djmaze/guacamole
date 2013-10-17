# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/collection'

class Test
end

class TestCollection
  include Guacamole::Collection
end

describe Guacamole::Collection do
  subject { TestCollection }

  describe 'Configuration' do
    it 'should set the connection to the ArangoDB collection' do
      mock_collection_connection = double('ConnectionToCollection')
      subject.connection         = mock_collection_connection

      expect(subject.connection).to eq mock_collection_connection
    end

    it 'should set the Mapper instance to map documents to models and vice versa' do
      mock_mapper    = double('Mapper')
      subject.mapper = mock_mapper

      expect(subject.mapper).to eq mock_mapper
    end

    it 'should set the connection to ArangoDB' do
      mock_db          = double('Ashikawa::Core::Database')
      subject.database = mock_db

      expect(subject.database).to eq mock_db
    end

    it 'should know the name of the collection in ArangoDB' do
      expect(subject.collection_name).to eq "test"
    end

    it 'should know the class of the model to manage' do
      expect(subject.model_class).to eq Test
    end
  end

  let(:connection) { double('Connection') }
  let(:mapper)     { double('Mapper') }

  before do
    subject.connection = connection
    subject.mapper     = mapper
  end

  describe 'by_key' do
    it 'should get mapped documents by key from the database' do
      document           = { data: 'foo' }
      model              = double('Model')

      expect(connection).to receive(:fetch).with('some_key').and_return(document)
      expect(mapper).to receive(:document_to_model).with(document).and_return(model)

      expect(subject.by_key('some_key')).to eq model
    end
  end

  describe 'save' do

    before do
      allow(connection).to receive(:create_document).with(document).and_return(document)
      allow(mapper).to receive(:model_to_document).with(model).and_return(document)
    end

    let(:key)       { double('Key') }
    let(:rev)       { double('Rev') }
    let(:document)  { double('Document', key: key, revision: rev).as_null_object }
    let(:model)     { double('Model').as_null_object }

    context 'a valid model' do
      before do
        allow(model).to receive(:valid?).and_return(true)
      end

      it 'should create a document' do
        expect(connection).to receive(:create_document).with(document).and_return(document)
        expect(mapper).to receive(:model_to_document).with(model).and_return(document)

        subject.save model
      end

      it 'should return the model after calling save' do
        expect(subject.save(model)).to eq model
      end

      it 'should set timestamps before creating the document' do
        now = double('Time.now')

        allow(Time).to receive(:now).once.and_return(now)

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

      it 'should not be used to create the document' do
        expect(connection).to receive(:create_document).never

        subject.save model
      end

      it 'should not be changed' do
        expect(model).to receive(:created_at=).never
        expect(model).to receive(:updated_at=).never
        expect(model).to receive(:key=).never
        expect(model).to receive(:rev=).never

        subject.save model
      end

      it 'should return false' do
        expect(subject.save(model)).to be false
      end
    end
  end

  describe 'delete' do
    let(:document) { double('Document') }
    let(:key)      { double('Key') }

    before do
      allow(connection).to receive(:fetch).with(key).and_return(document)
      allow(document).to receive(:delete)
    end

    it 'should delete the according document' do
      expect(document).to receive(:delete)

      subject.delete key
    end

    it 'should return the according key' do
      expect(subject.delete(key)).to eq key
    end
  end

  describe 'replace' do
    let(:key)      { double('Key') }
    let(:rev)      { double('Rev') }
    let(:model)    { double('Model', key: key).as_null_object }
    let(:document) { double('Document').as_null_object }
    let(:response) { double('Hash') }

    before do
      allow(mapper).to receive(:model_to_document).with(model).and_return(document)
      allow(connection).to receive(:replace).and_return(response)
      allow(response).to receive(:[]).with('_rev').and_return(rev)
    end

    context 'a valid model' do
      before do
        allow(model).to receive(:valid?).and_return(true)
      end

      it 'should set the updated_at timestamp before replacing the document' do
        now = double('Time.now')

        allow(Time).to receive(:now).once.and_return(now)
        expect(model).to receive(:updated_at=).with(now)

        subject.replace model
      end

      it 'should replace the document by key via the connection' do
        expect(connection).to receive(:replace).with(key, document)

        subject.replace model
      end

      it 'should update the revision after replacing the document' do
        allow(connection).to receive(:replace).and_return(response).ordered
        expect(model).to receive(:rev=).with(rev).ordered

        subject.replace model
      end

      it 'should return the model' do
        expect(subject.replace(model)).to eq model
      end

      it 'should not update created_at' do
        expect(model).to receive(:created_at=).never

        subject.replace model
      end
    end

    context 'an invalid model' do
      before do
        allow(model).to receive(:valid?).and_return(false)
      end

      it 'should not be used to replace the document' do
        expect(connection).to receive(:replace).never

        subject.replace model
      end

      it 'should not be changed' do
        expect(model).to receive(:rev=).never
        expect(model).to receive(:updated_at=).never

        subject.replace model
      end

      it 'should return false' do
        expect(subject.replace(model)).to be false
      end
    end
  end
end
