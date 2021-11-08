defmodule LED do
  require Logger
  alias Blinkchain.Color

  def set(index, clr) when is_binary(clr) do
    Blinkchain.set_pixel({index, 0}, color(clr))
  end

  def set(index, clr) do
    Blinkchain.set_pixel({index, 0}, clr)
  end

  def set_list(indices, clr) do
    for i <- indices,  do: set(i, clr)
  end

  def fill(from, to, clr) do
    Logger.debug "#{from} #{to} #{clr}"
    Blinkchain.fill({from,0}, to, 1, color(clr))
  end

  def off() do
    fill(0, 299, "#00000000")
  end

  def rcolor() do
    {
      :rand.uniform(256)-1,
      :rand.uniform(256)-1,
      :rand.uniform(256)-1,
      255
    }
  end

  def render() do
    try  do
      Blinkchain.render()
      Logger.debug "Rendered"
    rescue
      e -> Logger.error "oops rendering"
    end
  end

  def color(<<"#", r::2-bytes, g::2-bytes, b::2-bytes, w::2-bytes>>) do
    c = %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16),
      w: String.to_integer(w, 16)
    }
    c
  end

  def color(<<"#", r::2-bytes, g::2-bytes, b::2-bytes>>) do
    c = %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16)
    }
    c
  end
end
