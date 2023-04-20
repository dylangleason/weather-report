class WeatherController < ApplicationController
  include Infra

  rescue_from GeocoderError, with: :geocoder_error
  rescue_from WeatherError, with: :weather_error

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
    # TODO respond with an informative message indicating that
    # geocoding services are unavailable
  end

  def weather_error
    # TODO respond with an informative message indicating that weather
    # services are temporarily unavailable.
  end
end
