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
            rnk = Ranking.new
            rnk.content = ranking_items_array
            rnk.location = loc
            rnk.save!
            changed = true
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
