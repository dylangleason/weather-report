require "#{Rails.root}/lib/infra/geocoder"
require "#{Rails.root}/lib/infra/weather"

class WeatherController < ApplicationController
  include Infra

  rescue_from GeocoderAPIError, with: :geocoder_error
  rescue_from WeatherAPIError, with: :weather_error

  ##
  # Handle a request to render the main application view, including an
  # input form where the user can enter their zipcode.
  #
  def index
  end

  ##
  # Handle a request to obtain the current Weather Report given a
  # +zipcode+ parameter, returning a JSON response for use via XHR
  # request.
  #
  def show
    weather_service = ApplicationHelper.create_weather_service
    result = weather_service.current_weather(params[:zipcode])
    render json: result
  end

  private

  def geocoder_error
    render(
      json: {
        error: "geocoder API unavailable"
      },
      status: :service_unavailable
    )
  end

  def weather_error
    render(
      json: {
        error: "weather API unavailable"
      },
      status: :service_unavailable
    )
  end
end
