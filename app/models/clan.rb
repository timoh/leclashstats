class Clan
  include Mongoid::Document
  include Mongoid::Timestamps
  field :tag, type: String
  field :name, type: String
  field :badgeUrls, type: Hash

  has_many :player_rankings
end
