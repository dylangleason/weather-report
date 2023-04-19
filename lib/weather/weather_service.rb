module Weather
  ##
  # WeatherService provides services for querying weather data based on zipcode.
  #
  class WeatherService
    CACHE_EXPIRATION_SECONDS = 30 * 60

    ##
    # Creates a new weather service given an instance of +weather_api+
    # and +geocoder_api+.
    #
    def initialize(cache, weather_api, geocoder_api)
      @cache = cache
      @weather_api = weather_api
      @geocoder_api = geocoder_api
    end

    ##
    # Query the current weather by +zipcode+, first checking the
    # cache, then querying the external Weather API if the value is
    # missing in cache.
    #
    def current_weather(zipcode)
      result = @cache.hgetall(zipcode)
      return result unless result.empty?

      latlon = @geocoder_api.geocode_from_zipcode(zipcode)
      weather = @weather_api.current_weather(latlon[:lat], latlon[:lon])

      # Set the hash value for the weather data
      cache_weather(zipcode, weather)
      weather
    end

    private

    def cache_weather(zipcode, weather)
      @cache.hset(zipcode, weather)
      @cache.expire(zipcode, CACHE_EXPIRATION_SECONDS)
    end
  end
end
