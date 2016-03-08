class HomeController < ApplicationController
  caches_page :index, :country_json, :us_json, :global_json
  #caches_action :index, :country_json, :us_json, :global_json

  def index
    @country_name = 'United States'
    @us_topten = Location.get_us_topten
  end

  def country_json
    begin
    country_id = params[:country_id].to_i
    @top_ten_for_country = PlayerRanking.get_top(country_id, 10)
    rescue
      @top_ten_for_country = {}
    end

    render json: @top_ten_for_country
  end

  def us_json
    begin
      us_id = Location.find_by({name: "United States"}).api_id
      @us_players = PlayerRanking.get_top(us_id, 10)
    rescue
      @us_players = {}
    end

    render json: @us_players
  end

  def global_json
    begin
      @global_top_list = Location.construct_global_top_lists
    rescue
      @global_top_list = {}
    end

    render json: @global_top_list
  end
end
