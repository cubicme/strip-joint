require 'net/http'
require 'uri'
require 'json'

HOST = 'http://192.168.2.132:4000'
COUNT = 300

def post(path, body)
  Net::HTTP.post(URI.join(HOST, 'modes/', path), body.to_json, "Content-Type" => "application/json")
end

def delete(path)
  uri = URI.join(HOST, 'modes/', path)
  Net::HTTP.new(uri.host, uri.port).delete(uri.path)
end

def c(v)
  s = v.to_s(16)
  s = "0#{s}" if s.length == 1
  s
end

def hex(r, g, b)
  "\##{c(r)}#{c(g)}#{c(b)}#{c(255)}"
end


delete('') # kill current mode
post('', {mode: 'manual'})
delete('set') # turn off all LEDs

while true
  (0..(COUNT-1)).each do |i|
    post("set/#{i}", {color: hex(rand(255), rand(255), rand(255))})
    j = i - 30
    j += COUNT if j < 0

    delete("set/#{j}")
  end
end
