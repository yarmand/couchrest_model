class  Parent < CouchRest::Model::Base
  property :name, String

  belongs_to :super_power
  belongs_to :husband, :class_name => :parent, :reverse_association => :wife
  belongs_to :wife, :class_name => :parent, :reverse_association => :husband
  belongs_to :lives_with, :class_name => :parent, :reverse_association => :lives_with

  collection_of :children, :class_name => 'Kid'
  collection_of :pets , :reverse_association => :owner
end
