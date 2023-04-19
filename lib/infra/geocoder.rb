require "uri"
require "net/http"

module Infra
  class GeocoderAPIError < StandardError
  end

  class GeocoderAPI
    HOSTNAME = "http://api.openweathermap.org/geo/1.0/zip"

    ##
    # Create an instance of the GeocoderAPI given an +api_key+ for
    # authorizing requests.
    def initialize(api_key)
      @api_key = api_key
    end

    ##
    # Fetch the geocoordinates for the +zipcode+ and +country_code+
    # (defaults to US), or raise an error.
    def geocode_from_zipcode(zipcode, country_code = "US")
      uri = URI("#{HOSTNAME}?zip=#{zipcode},#{country_code}&appid=#{@api_key}")
      res = Net::HTTP.get_response(uri)
      Infra.handle_response(res, GeocoderAPIError)
    end
  end
end
