class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  field :api_id, type: Integer
  field :name, type: String
  field :last_fetched, type: DateTime, default: DateTime.new(1970,1,1)

  validates :api_id, :name, :last_fetched, presence: true
  has_many :rankings

  def self.construct_global_top_lists
    locs = Location.all.cache

    result_hash = {}
    locs.each do |loc|
      top_list = PlayerRanking.get_top(loc.api_id, 10)
      result_hash[loc.api_id] = {}
      top_list.each do |player|
        result_hash[loc.api_id] = Hash[player.rank, player]
      end
    end
  end

  def self.reset_fetch_dates
    locs = Location.all.cache
    locs.each do |loc|
      loc.last_fetched = DateTime.new(1970,1,1)
      loc.save!
    end
  end

  def self.fetch_location(token)
    require 'json'
    require 'rest-client'
    puts "Starting to fetch locations from API."
    changed = false # a variable to keep track of whether or not a cache flush is warranted
    # curl -X GET --header "Accept: application/json" --header "authorization: Bearer <API token>" "https://api.clashofclans.com/v1/locations"
    response = RestClient.get 'https://api.clashofclans.com/v1/locations', :content_type => :json, :accept => :json, :authorization => "Bearer #{token}"
    locations_items_array = JSON.parse(response.body)["items"]
    puts "HTTP GET succeeded. Iterating over items in JSON response."
    locations_items_array.each do |loc_item|
      country = loc_item["isCountry"]
      if country
        api_id = loc_item["id"]
        name = loc_item["name"]
        begin
          loc = Location.find_by!(api_id)
        rescue
          loc = Location.create
          loc.api_id = api_id
          loc.name = name
          loc.save!
          changed = true
        end
      end
    end
    puts "Fetching completed. Proceeding to expire cache."
    if changed == true
      ActionController::Base::expire_page("/")
      Rails.logger.info("Removed page cache")
      puts "Cache expired. Task successful. Exiting."
    else
      puts "Nothing changed – cache intact. Task otherwise successful. Exiting."
    end

  end
end
