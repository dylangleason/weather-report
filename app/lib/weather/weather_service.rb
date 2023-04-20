module Weather
  TemperatureData = Struct.new(:current, :high, :low, :cached)

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
      return from_cache(result) unless result.empty?

      latlon = @geocoder_api.geocode_from_zipcode(zipcode)
      weather = @weather_api.current_weather(latlon["lat"], latlon["lon"])
      temps = from_api(weather)

      # Set the hash value for the weather data
      cache_temps(zipcode, temps)
      temps
    end

    private

    def from_api(weather)
      temps = weather["main"]
      TemperatureData.new(
        temps["temp"],
        temps["temp_max"],
        temps["temp_min"],
        false
      )
    end

    def from_cache(temps)
      TemperatureData.new(
        temps["current"].to_f,
        temps["high"].to_f,
        temps["low"].to_f,
        true
      )
    end

    def cache_temps(zipcode, temps)
      @cache.hmset(
        zipcode,
        "current",
        temps.current,
        "high",
        temps.high,
        "low",
        temps.low
      )
      @cache.expire(zipcode, CACHE_EXPIRATION_SECONDS)
    end
  end
end
