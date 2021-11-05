defmodule LED do
  require Logger
  alias Blinkchain.Color

  def set(index, clr) do
    Blinkchain.set_pixel({index, 0}, color(clr))
  end

  def fill(from, to, clr) do
    Logger.info "#{from} #{to} #{clr}"
    Blinkchain.fill({from,0}, to, 1, color(clr))
  end

  def render() do
    try  do
      Blinkchain.render()
      Logger.info "Rendered"
    rescue
      e -> Logger.info "oops rendering"
    end
  end

  def color(<<"#", r::2-bytes, g::2-bytes, b::2-bytes, w::2-bytes>>) do
    c = %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16),
      w: String.to_integer(w, 16)
    }
    IO.inspect c
    c
  end

  def color(<<"#", r::2-bytes, g::2-bytes, b::2-bytes>>) do
    c = %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16)
    }
    IO.inspect c
    c
  end
end
