class SuperPower < CouchRest::Model::Base
  property :description, String

  belongs_to :parent
end
