class LocationsController < ApplicationController
  def index
    @locations = Location.all
  end

  def api_id
    api_id = params[:api_id]
    puts "Api ID is: #{api_id}"
    @location = Location.find_by({:api_id => api_id})
  end
end
