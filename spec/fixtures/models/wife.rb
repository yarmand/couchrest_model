class  Wife < CouchRest::Model::Base
  property :name, [String]

  belongs_to :husband

  collection_of :children, :class_name => 'Kid'
end
