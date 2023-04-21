require "net/http/persistent"

HTTP_CLIENT = Net::HTTP::Persistent.new(name: "weather-report")
