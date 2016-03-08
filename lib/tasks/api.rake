namespace :api do
  require 'rest-client'
  require 'json'

  desc "Delete all rankings"
  task :delete_all_rankings => :environment do
    puts "Proceeding to flush rankings and reset fetch dates."
    PlayerRanking.delete_all
    Location.reset_fetch_dates
    puts "Task successful. Exiting."
  end

  desc "Fetch the locations from the API"
  task :fetch_location, [:token] => [:environment] do |t, args|
    raise "Not an integer" unless args.token.is_a? String
    Location.fetch_location(args.token)
  end

  desc "Fetch the rankings from the API"
  task :fetch_ranks, [:token] => [:environment] do |t, args|
    raise "Not an integer" unless args.token.is_a? String
    PlayerRanking.fetch_rankings(args.token)
  end

end
