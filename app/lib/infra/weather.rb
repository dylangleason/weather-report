require "uri"
require "net/http"

module Infra
  class WeatherError < StandardError
  end

  ##
  # WeatherAPI will fetch current weather data from OpenWeather.
  #
  # TODO: consider using a Singleton instance and set to the lifecycle
  # of the application so that we can rate limit requests.
  #
  class WeatherApi
    HOSTNAME = "https://api.openweathermap.org/data/2.5/weather"

    ##
    # Create an instance of the WeatherAPI given an +api_key+ for
    # authorizing requests.
    def initialize(api_key)
      @api_key = api_key
    end

    ##
    # Fetch the current weather given geocoordinates +lat+ and
    # +lon+. Note that units for results are specified in imperial
    # units. If the response is not successful, raise an error.
    def current_weather(lat, lon)
      uri =
        URI(
          "#{HOSTNAME}?lat=#{lat}&lon=#{lon}&units=imperial&appid=#{@api_key}"
        )
      res = Net::HTTP.get_response(uri)
      Infra.handle_response(res, WeatherError)
    end
  end
end
