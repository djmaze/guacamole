# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/document_model_mapper'

class FancyModel
end

describe Guacamole::DocumentModelMapper do
  subject { Guacamole::DocumentModelMapper }

  it 'should be initialized with a model class' do
    mapper = subject.new FancyModel
    expect(mapper.model_class).to eq FancyModel
  end

  describe 'document_to_model' do
    subject { Guacamole::DocumentModelMapper.new FancyModel }

    let(:document)            { double('Ashikawa::Core::Document') }
    let(:document_attributes) { double('Hash') }
    let(:model_instance)      { double('ModelInstance').as_null_object }
    let(:some_key)            { double('Key') }
    let(:some_rev)            { double('Rev') }

    before do
      allow(subject.model_class).to receive(:new).and_return(model_instance)
      allow(document).to receive(:hash).and_return(document_attributes)
      allow(document).to receive(:key).and_return(some_key)
      allow(document).to receive(:revision).and_return(some_rev)
    end

    it 'should create a new model instance from an Ashikawa::Core::Document' do
      expect(subject.model_class).to receive(:new).with(document_attributes)

      model = subject.document_to_model document
      expect(model).to eq model_instance
    end

    it 'should set the rev and key on a new model instance' do
      expect(model_instance).to receive(:key=).with(some_key)
      expect(model_instance).to receive(:rev=).with(some_rev)

      subject.document_to_model document
    end
  end

  describe 'model_to_document' do
    subject { Guacamole::DocumentModelMapper.new FancyModel }

    let(:model)            { double('Model') }
    let(:model_attributes) { double('Hash').as_null_object }

    before do
      allow(model).to receive(:attributes).and_return(model_attributes)
      allow(model_attributes).to receive(:dup).and_return(model_attributes)
    end

    it 'should transform a model into a simple hash' do
      expect(subject.model_to_document(model)).to eq model_attributes
    end

    it 'should return a copy of the model attributes hash' do
      expect(model_attributes).to receive(:dup).and_return(model_attributes)

      subject.model_to_document(model)
    end

    it 'should remove the key and rev attributes from the document' do
      expect(model_attributes).to receive(:except).with(:key, :rev)

      subject.model_to_document(model)
    end
  end

  describe 'embed' do
    subject { Guacamole::DocumentModelMapper.new FancyModel }

    it 'should remember which models to embed' do
      subject.embeds :ponies

      expect(subject.models_to_embed).to include :ponies
    end
  end
end
