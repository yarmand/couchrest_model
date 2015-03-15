class Pet < CouchRest::Model::Base
  property :name, String

  belongs_to :walker, :class_name => 'Parent'
  belongs_to :owner, :class_name => 'Parent'
end
