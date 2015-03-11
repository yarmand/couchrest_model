class  Kid < CouchRest::Model::Base
  property :name, String

  belongs_to :dad, :class_name => 'Parent'
  belongs_to :mum, :class_name => 'Parent'

end
