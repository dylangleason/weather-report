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

    @expected_result = { "temp" => "43" }

    lat = 37.33
    lon = -122.01
    @geocoder_api.expect :geocode_from_zipcode,
                         { lat: lat, lon: lon },
                         [@zipcode]
    @weather_api.expect :current_weather, @expected_result, [lat, lon]
  end

  describe "#current_weather" do
    describe "given a zipcode stored in cache" do
      before { @cache.hset(@zipcode, @expected_result) }

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
        expect(data).must_equal(@expected_result)
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

      it "then store the value in cache for later" do
        @weather_service.current_weather(@zipcode)
        data = @cache.hgetall(@zipcode)
        expect(data).must_equal(@expected_result)
      end
    end
  end
end
