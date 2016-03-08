class League
  include Mongoid::Document
  include Mongoid::Timestamps
  field :api_id, type: Integer
  field :name, type: String
  field :iconUrls, type: Hash

  has_many :player_rankings
end
