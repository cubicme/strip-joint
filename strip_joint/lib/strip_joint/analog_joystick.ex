# https://tutorials-raspberrypi.com/raspberry-pi-joystick-with-mcp3008/
# https://dev.to/mnishiguchi/elixir-nerves-potentiometer-with-spi-based-analog-to-digital-converter-25h1
 
defmodule AnalogJoystick do
  use Bitwise

  @sw 0
  @x  1
  @y  2

  def x(device), do: device |> get(@x) |> normalize
  def y(device), do: device |> get(@y) |> normalize
  def sw(device), do: device |> get(@sw) |> normalize

  defp get(device, ch) do
    payload = <<1, 0b10000000 ||| (ch <<< 4), 0>>
    {:ok, <<_::size(14), value::size(10)>>} = Circuits.SPI.transfer(device, payload)
    value
  end


  def normalize(x), do: map_range(x, {0, 1023}, {-1, 1}) |> Float.round(1)

  @doc """
  ## Examples
  iex> MyModule.map_range(65, {0, 1023}, {0, 100})
  6.35386119257087
  """
  defp map_range(x, {in_min, in_max}, {out_min, out_max}) do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end

  def get_device() do
    {:ok, ref} = Circuits.SPI.open("spidev0.0", speed_hz: 1000)
    ref
  end
end
