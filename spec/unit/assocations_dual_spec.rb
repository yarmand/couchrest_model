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
        mummy.husband.should eql(father)
      end
    end

    context 'the other side do not back associate (1-0)' do
      let(:invoice) { SaleInvoice.create(:price => 2000) }
      let(:client)  { Client.create(:name => "Sam Lown") }
      it 'should set property without error' do
        lambda { invoice.client = client }.should_not raise_error
      end

    end

    context 'the other side associate as a collection (1-n)' do
      it 'should be part of the collection when setting the property' do
        kid.dad = father
        father.children.should include(kid)
      end
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
