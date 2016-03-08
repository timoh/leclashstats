class Ranking
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: Hash
  belongs_to :location

  def self.fetch_rankings(token)
    require 'json'
    require 'rest-client'
    changed = false # a variable to keep track of whether or not a cache flush is warranted

    puts "Fetching locations which haven't had fetches in a while first."
    locs = Location.where(:last_fetched.lte => Time.now-1.hour).cache
    puts "The amount of locations to be fetched is: #{locs.size}"

    begin
      locs.each do |loc|
        puts "\n --- Fetching rankings for #{loc.name}. Time is: #{DateTime.now.to_s(:short)}"
        loc_id = loc.api_id
        raise "Location ID is not an integer!" unless loc_id.is_a? Integer
        puts "Attempting to do an API call now."
        begin
          # curl -X GET --header "Accept: application/json" --header "authorization: Bearer <API token>" "https://api.clashofclans.com/v1/locations/32000086/rankings/players"
          begin
            response = RestClient.get "https://api.clashofclans.com/v1/locations/#{loc_id}/rankings/players", :content_type => :json, :accept => :json, :authorization => "Bearer #{token}"
          rescue => e
            puts e.response
          else
            ranking_items_array = JSON.parse(response.body)["items"]
            # puts "HTTP GET succeeded. Iterating over items in JSON response."
            ranking_items_array.each do |ranking_item|
              plr = PlayerRanking.new
              plr.location = loc
              plr.location_id = loc_id
              plr.name = ranking_item["name"]
              plr.expLevel = ranking_item["expLevel"]
              plr.trophies = ranking_item["trophies"]
              plr.attackWins = ranking_item["attackWins"]
              plr.defenseWins = ranking_item["defenseWins"]
              plr.rank = ranking_item["rank"]
              plr.previousRank = ranking_item["previousRank"]
              # TODO: Add clan and league information!
              plr.save!
              changed = true
            end
          end
        rescue => e
          puts e
        else
          loc.last_fetched = DateTime.now
          loc.save!
          puts "Rankings for #{loc.name} fetched successfully on #{DateTime.now.to_s(:short)}"
        end
      end
    rescue => e
      puts e
    else
      puts "Fetching completed."
      if changed == true && locs.size > 0
        puts "Proceeding to expire cache."
        ActionController::Base::expire_page("/")
        Rails.logger.info("Removed page cache")
        puts "Cache expired. Task successful. Exiting."
      else
        puts "Nothing changed – cache intact. Task otherwise successful. Exiting."
      end
    end
  end

end
