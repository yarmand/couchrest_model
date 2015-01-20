# encoding: utf-8
require 'spec_helper'

describe 'Associations' do

  describe 'of type belongs_to' do
    context 'the other side also belongs_to (1-1)' do
      it 'should set the other side property too' do
      end
    end

    context 'the other side do not back associate (1-0)' do
      it 'should set property without error' do
      end
    end

    context 'the other side associate as a collection (1-n)' do
      it 'should be part of the collection weh setting the property' do
      end
    end
  end

  descibe 'of type collection_of' do
    context 'the other side is a belongs_to (n-1)' do
      it 'should populate the belongs_to property when added to the collection'
    end

    context 'the other side do not back associate (n-0)' do
      it 'should set property without error' do
      end
    end
  end
end
