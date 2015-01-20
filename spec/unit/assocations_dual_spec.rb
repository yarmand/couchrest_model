# encoding: utf-8
require 'spec_helper'

describe 'Associations' do

  let(:father) { Husband.create(name: 'bob')}
  let(:mummy)  { Wife.create(   name: 'claire')}
  let(:kid)    { Kid.create(    name: 'Vladimir')}

  describe 'of type belongs_to' do
    context 'the other side also belongs_to (1-1)' do
      it 'should set the other side property too' do
        father.wife = mummy
        expect(mummy.husband).to eq(father)
      end
    end

    context 'the other side do not back associate (1-0)' do
      it 'should set property without error'

    end

    context 'the other side associate as a collection (1-n)' do
      it 'should be part of the collection weh setting the property'
    end
  end

  describe 'of type collection_of' do
    context 'the other side is a belongs_to (n-1)' do
      it 'should populate the belongs_to property when added to the collection'
    end

    context 'the other side do not back associate (n-0)' do
      it 'should set property without error'
    end
  end
end
