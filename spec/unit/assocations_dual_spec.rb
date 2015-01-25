# encoding: utf-8
require 'spec_helper'

describe 'Associations' do

  let(:father) { Husband.create(name: 'bob')}
  let(:mummy)  { Wife.create(   name: 'claire')}
  let(:kid)    { Kid.create(    name: 'Vladimir')}

  describe 'of type belongs_to' do
    context 'with the other side also belongs_to (1-1)' do
      it 'should set the other side property too' do
        father.wife = mummy
        mummy.husband.should eql(father)
      end

      it 'should remove the other side if value is nil' do
        father.wife = mummy
        father.wife = nil
        mummy.husband.should be_nil
      end
    end

    context 'with the other side do not back associate (1-0)' do
      let(:invoice) { SaleInvoice.create(:price => 2000) }
      let(:client)  { Client.create(:name => "Sam Lown") }
      it 'should set property without error' do
        lambda { invoice.client = client }.should_not raise_error
      end

    end

    context 'with the other side associate as a collection (1-n)' do
      it 'should be part of the collection when setting the property' do
        kid.dad = father
        father.children.should include(kid)
      end
    end

    describe 'when object is saved' do
      it 'should also save other side' do
        father.wife = mummy
        mummy.should_receive(:save)
        father.save
      end
  end

  end

  describe 'of type collection_of' do
    context 'with the other side is a belongs_to (n-1).' do
      context 'Adding to the collection using <<' do
        it 'should populate the belongs_to property' do
          father.children << kid
          kid.dad.should eq(father)
        end
      end

      context 'Adding to the collection using push' do
        it 'should populate the belongs_to property' do
          father.children.push kid
          kid.dad.should eq(father)
        end
      end

      context 'Adding to the collection using unshift' do
        it 'should populate the belongs_to property' do
          father.children.unshift kid
          kid.dad.should eq(father)
        end
      end

      context 'Adding to the collection using [n]=' do
        it 'should populate the belongs_to property' do
          father.children[3]= kid
          kid.dad.should eq(father)
        end
      end

      context 'removing from the collection using pop' do
        it 'should set nil the belongs_to property' do
          father.children.push kid
          father.children.pop
          kid.dad.should be_nil
        end
      end

      context 'removing from the collection using shift' do
        it 'should set nil the belongs_to property' do
          father.children.push kid
          father.children.shift
          kid.dad.should be_nil
        end
      end

    end

    context 'with the other side do not back associate (n-0)' do
      let(:invoice) { SaleInvoice.create(:price => 2000) }
      let(:entry)  { SaleEntry.create(:description => 'test line 1', :price => 500) }

      context 'Adding to the collection using <<' do
        it 'should set property without error' do
          lambda { invoice.entries << entry}.should_not raise_error
        end
      end

      context 'Adding to the collection using push' do
        it 'should set property without error' do
          lambda { invoice.entries.push entry}.should_not raise_error
        end

      context 'Adding to the collection using unshift' do
        it 'should set property without error' do
          lambda { invoice.entries.unshift entry}.should_not raise_error
        end
      end

      context 'Adding to the collection using []=' do
        it 'should set property without error' do
          lambda { invoice.entries[3]= entry}.should_not raise_error
        end
      end

      context 'removing from the collection using pop' do
        it 'should set nil the belongs_to property' do
          invoice.entries.push entry
          lambda { invoice.entries.pop }.should_not raise_error
        end
      end

      context 'removing from the collection using shift' do
        it 'should set nil the belongs_to property' do
          invoice.entries.push entry
          lambda { invoice.entries.shift }.should_not raise_error
        end
      end

      end
    end
  end

end
