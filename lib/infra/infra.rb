require "json"

module Infra
  ##
  # Handle a network response by either returning +res+ or raising an
  # error of type +klass+.
  def self.handle_response(res, klass)
    case res
    when Net::HTTPSuccess
      if !res.class.body_permitted?
        raise klass.new("response did not contain a body")
      end
      JSON.parse(res.body)
    else
      raise klass.new("error returned with code #{code}")
    end
  end
end
