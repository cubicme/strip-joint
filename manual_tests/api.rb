require 'net/http'
require 'uri'
require 'json'

HOST = 'http://192.168.2.132:4000'
COUNT = 600

class LED
  class << self
    def post(path, body)
      Net::HTTP.post(URI.join(HOST, 'modes/', path), body.to_json, "Content-Type" => "application/json")
    end

    def delete(path)
      uri = URI.join(HOST, 'modes/', path)
      Net::HTTP.new(uri.host, uri.port).delete(uri.path)
    end
  end
end
