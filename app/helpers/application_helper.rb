module ApplicationHelper
  include Infra

  def self.create_weather_service()
    api_key = ENV["OPENWEATHER_API_KEY"]

    if api_key.nil? || api_key.empty?
      raise ArgumentError.new("OpenWeather API key is missing")
    end

    geocode_api = GeocoderApi.new(api_key)
    weather_api = WeatherApi.new(api_key)
    Weather::WeatherService.new(REDIS, weather_api, geocode_api)
  end
end
