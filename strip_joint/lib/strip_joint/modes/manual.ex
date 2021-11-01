defmodule StripJoint.Modes.Manual do
  use GenServer
  require Logger

  alias Blinkchain.Color

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info "Manual Init"
    {:ok, 0}
  end

  # GenServer callbacks

  def handle_call({:set, index, color}, _caller, state) do
    Blinkchain.set_pixel({index, 0}, parse(color))
    Logger.info "#{index} to #{color}"
    render()
    {:reply, :ok, state}
  end

  def handle_call({:off}, _caller, state) do
    fill(0, 244, "#00000000")
    render()
    {:reply, :ok, state}
  end

  def handle_call({:off, index}, _caller, state) do
    Logger.info "off \##{index}"
    Blinkchain.set_pixel({index, 0}, {0, 0, 0, 0})
    render()
    {:reply, :ok, state}
  end

  def handle_call({:brightness, value}, _caller, state) do
    Logger.info "brightness #{value}"
    Blinkchain.set_brightness(0, value)
    render()
    {:reply, :ok, state}
  end

  defp fill(from, to, color) do
    Logger.info "#{from} #{to} #{color}"
    Blinkchain.fill({from,0}, to, 0, parse(color))
  end

  defp render() do
    try  do
      Blinkchain.render()
      Logger.info "Rendered"
    rescue
      e -> Logger.info "oops rendering"
    end
  end

  def parse(<<"#", r::2-bytes, g::2-bytes, b::2-bytes, w::2-bytes>>) do
    c = %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16),
      w: String.to_integer(w, 16)
    }
    IO.inspect c
    c
  end

  def parse(<<"#", r::2-bytes, g::2-bytes, b::2-bytes>>) do
    c = %Color{
      r: String.to_integer(r, 16),
      g: String.to_integer(g, 16),
      b: String.to_integer(b, 16)
    }
    IO.inspect c
    c
  end
end
