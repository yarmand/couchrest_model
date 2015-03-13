# encoding: utf-8
require 'spec_helper'

describe 'Associations' do

  let(:father) { Parent.create(name: 'Bob')}
  let(:can_fly){ SuperPower.create(description: 'Can fly when there is no cloud')}
  let(:mummy)  { Parent.create(name: 'Claire')}
  let(:kid)    { Kid.create(   name: 'Vladimir')}
  let(:dog)    { Pet.create(   name: 'Valdo' )}

  describe 'of type belongs_to' do
    context 'with the other side also belongs_to (1-1)' do
      context '[non ambiguous association]' do
        it 'should set the other side property too' do
          father.super_power = can_fly
          can_fly.parent.should eql father
        end
      end

      context '[ambiguous association]' do
        it 'should set the other side property too' do
          father.wife = mummy
          mummy.husband.should eql(father)
        end
      end

      context '[cyclic association]' do
        it 'should set the other side property too' do
          father.lives_with = mummy
          mummy.lives_with.should eql(father)
        end
      end
    end

    context 'with the other side do not back associate (1-0)' do
      let(:invoice) { SaleInvoice.create(:price => 2000) }
      let(:client)  { Client.create(:name => "Sam Lown") }
      it 'should set property without error' do
        invoice.client = client
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
      it 'should not call save twice in a row' do
        father.wife = mummy
        mummy.should_receive(:save).exactly(1)
        father.save
        father.name = 'rogers'
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
        context 'when reverse_association is specified' do
          it 'should populate the belongs_to property' do
            father.pets << dog
            dog.owner.should eq(father)
          end
        end
        describe 'when object is saved' do
          it 'should also save other side' do
            father.children << kid
            kid.should_receive(:save)
            father.save
          end
        end
      end

      context 'Adding to the collection using push' do
        it 'should populate the belongs_to property' do
          father.children.push kid
          kid.dad.should eq(father)
        end
        context 'when reverse_association is specified' do
          it 'should populate the belongs_to property' do
            father.pets.push dog
            dog.owner.should eq(father)
          end
        end
        describe 'when object is saved' do
          it 'should also save other side' do
            father.children.push kid
            kid.should_receive(:save)
            father.save
          end
        end
      end

      context 'Adding to the collection using unshift' do
        it 'should populate the belongs_to property' do
          father.children.unshift kid
          kid.dad.should eq(father)
        end
        it 'should populate the belongs_to property' do
          father.pets.unshift dog
          dog.owner.should eq(father)
        end
        describe 'when object is saved' do
          it 'should also save other side' do
            father.children.unshift kid
            kid.should_receive(:save)
            father.save
          end
        end
      end

      context 'Adding to the collection using [n]=' do
        it 'should populate the belongs_to property' do
          father.children[3]= kid
          kid.dad.should eq(father)
        end
        it 'should populate the belongs_to property' do
          father.pets[3] = dog
          dog.owner.should eq(father)
        end
        describe 'when object is saved' do
          it 'should also save other side' do
            father.children[4] = kid
            kid.should_receive(:save)
            father.save
          end
        end
      end

      context 'removing from the collection using pop' do
        it 'should set nil the belongs_to property' do
          father.children.push kid
          father.children.pop
          kid.dad.should be_nil
        end
        context 'specifying reverse association' do
          it 'should set nil the belongs_to property' do
            father.pets.push dog
            father.pets.pop
            dog.owner.should be_nil
          end
        end
        describe 'when object is saved' do
          it 'should also save other side' do
            father.children.push kid
            father.save
            father.children.pop
            kid.should_receive(:save)
            father.save
          end
        end
      end

      context 'removing from the collection using shift' do
        it 'should set nil the belongs_to property' do
          father.children.push kid
          father.children.shift
          kid.dad.should be_nil
        end
        context 'specifying reverse association' do
          it 'should set nil the belongs_to property' do
            father.pets.push dog
            father.pets.shift
            dog.owner.should be_nil
          end
        end
        describe 'when object is saved' do
          it 'should also save other side' do
            father.children.push kid
            father.save
            father.children.shift
            kid.should_receive(:save)
            father.save
          end
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
