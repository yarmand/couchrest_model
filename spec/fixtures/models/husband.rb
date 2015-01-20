class  Husband < CouchRest::Model::Base
  property :name, String

  belongs_to :wife

  collection_of :children, :class_name => 'Kid'
end
