class  Kid < CouchRest::Model::Base
  property :name, [String]

  belongs_to :dad, :class_name => 'Husband'
  belongs_to :mum, :class_name => 'Wife'

end
