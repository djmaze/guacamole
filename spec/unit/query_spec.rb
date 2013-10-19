# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'guacamole/query'

describe Guacamole::Query do
  let(:connection) { double('Connection') }
  let(:mapper) { double('Mapper') }

  subject { Guacamole::Query.new(connection, mapper) }

  its(:connection) { should be connection }
  its(:mapper) { should be mapper }

  it 'should be enumerable' do
    expect(Guacamole::Query.ancestors).to include Enumerable
  end

  describe 'each' do
    let(:result) { double }
    let(:document) { double }
    let(:model) { double }

    before do
      allow(result).to receive(:each)
        .and_yield(document)

      allow(mapper).to receive(:document_to_model)
        .and_return(model)
    end

    context 'no example was provided' do
      before do
        allow(connection).to receive(:all)
          .and_return(result)
      end

      it 'should get all documents' do
        expect(connection).to receive(:all)
          .with(no_args)

        subject.each { }
      end

      it 'should iterate over the resulting documents' do
        expect(result).to receive(:each)

        subject.each { }
      end

      it 'should yield the models to the caller' do
        expect { |b| subject.each(&b) }.to yield_with_args(model)
      end

      it 'should return an enumerator when called without a block' do
        expect(subject.each).to be_an Enumerator
      end
    end

    context 'an example was provided' do
      let(:example) { double }
      before do
        subject.example = example

        allow(connection).to receive(:by_example)
          .and_return(result)
      end

      it 'should query by the given example' do
        expect(connection).to receive(:by_example)
          .with(example)

        subject.each { }
      end

      it 'should iterate over the resulting documents' do
        expect(result).to receive(:each)

        subject.each { }
      end

      it 'should yield the models to the caller' do
        expect { |b| subject.each(&b) }.to yield_with_args(model)
      end

      it 'should return an enumerator when called without a block' do
        expect(subject.each).to be_an Enumerator
      end
    end
  end
end
