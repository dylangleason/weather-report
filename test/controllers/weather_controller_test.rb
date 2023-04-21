require "test_helper"
require "minitest/mock"

require "#{Rails.root}/lib/infra/geocoder"
require "#{Rails.root}/lib/infra/weather"
require "#{Rails.root}/lib/weather/weather_service"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  include Infra
  include Weather

  setup { @mock_service = Minitest::Mock.new }

  test "should respond with an error when geocoder API unavailable" do
    @mock_service.expect(:current_weather, nil, []) do
      raise GeocoderAPIError.new
    end

    WeatherService.stub :new, @mock_service do
      get "/weather/12345"
      assert_response :service_unavailable
      assert_equal '{"error":"geocoder API unavailable"}', @response.body
    end
  end

  test "should respond with an error when weather API unavailable" do
    @mock_service.expect(:current_weather, nil, []) do
      raise WeatherAPIError.new
    end

    WeatherService.stub :new, @mock_service do
      get "/weather/12345"
      assert_response :service_unavailable
      assert_equal '{"error":"weather API unavailable"}', @response.body
    end
  end

  test "should respond with temperature data" do
    @mock_service.expect(
      :current_weather,
      TemperatureData.new(40, 42, 39, false),
      ["12345"]
    )
    WeatherService.stub :new, @mock_service do
      get "/weather/12345"
      assert_response :success
      assert_equal(
        '{"current":40,"high":42,"low":39,"cached":false}',
        @response.body
      )
    end
  end
end
