require "test_helper"
require "minitest/autorun"
require "mock_redis"

require "#{Rails.root}/lib/weather/weather_service"

include Weather

describe WeatherService do
  before do
    @zipcode = "95014"
    @cache = MockRedis.new
    @weather_api = Minitest::Mock.new
    @geocoder_api = Minitest::Mock.new
    @weather_service = WeatherService.new(@cache, @weather_api, @geocoder_api)

    @expected_response = {
      "main" => {
        "temp" => 43.2,
        "temp_max" => 48.5,
        "temp_min" => 37.0
      }
    }

    @expected_result = TemperatureData.new(43.2, 48.5, 37.0)

    lat = 37.33
    lon = -122.01
    @geocoder_api.expect :geocode_from_zipcode,
                         { "lat" => lat, "lon" => lon },
                         [@zipcode]
    @weather_api.expect :current_weather, @expected_response, [lat, lon]
  end

  describe "#current_weather" do
    describe "given a zipcode stored in cache" do
      before do
        @cache.hmset(
          @zipcode,
          "current",
          @expected_result.current,
          "high",
          @expected_result.high,
          "low",
          @expected_result.low
        )
      end

      it "then do not query the geocoder API" do
        @weather_service.current_weather(@zipcode)
        _ { @geocoder_api.verify }.must_raise MockExpectationError
      end

      it "then do not query the weather API" do
        @weather_service.current_weather(@zipcode)
        _ { @weather_api.verify }.must_raise MockExpectationError
      end

      it "then return data stored in cache" do
        data = @weather_service.current_weather(@zipcode)
        cached_struct = @expected_result.clone
        cached_struct.cached = true
        expect(data).must_equal(cached_struct)
      end
    end

    describe "given a zipcode not stored in cache" do
      it "then query the geocoder API for lat/lon" do
        @weather_service.current_weather(@zipcode)
        @geocoder_api.verify
      end

      it "then query the weather API for weather data" do
        @weather_service.current_weather(@zipcode)
        @weather_api.verify
      end

      it "then return data from API" do
        data = @weather_service.current_weather(@zipcode)
        uncached_struct = @expected_result.clone
        uncached_struct.cached = false
        expect(data).must_equal(uncached_struct)
      end
    end
  end
end
