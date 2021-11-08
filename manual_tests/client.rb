require_relative 'api'


def c(v)
  s = v.to_s(16)
  s = "0#{s}" if s.length == 1
  s
end

def hex(r, g, b)
  "\##{c(r)}#{c(g)}#{c(b)}#{c(255)}"
end


LED.delete('') # kill current mode
LED.post('', {mode: 'manual'})
LED.delete('set') # turn off all LEDs

while true
  (0..(COUNT-1)).each do |i|
    LED.post("set/#{i}", {color: hex(rand(255), rand(255), rand(255))})
    j = i - 30
    j += COUNT if j < 0

    LED.delete("set/#{j}")
  end
end
