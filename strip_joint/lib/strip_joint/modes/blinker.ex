defmodule StripJoint.Modes.Blinker do
  use GenServer
  require Logger

  alias Blinkchain.Color
  alias Blinkchain.Point

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_state) do
    Process.send(self(), :init)
    {:ok, 0}
  end

  # GenServer callbacks
  def handle_info(:init, state) do
    Blinkchain.set_pixel(%Point{x: 0, y: 0}, %Color{r: 255, g: 0, b: 0, w: 255})
    Blinkchain.set_pixel(%Point{x: 1, y: 0}, %Color{r: 0, g: 255, b: 0, w: 255})
    Blinkchain.set_pixel(%Point{x: 2, y: 0}, %Color{r: 0, g: 0, b: 255, w: 255})
    try  do
      Blinkchain.render()
    rescue
      e -> IO.puts "oops"
    end

    Logger.debug("Init complete")

    Process.send_after(self(), :tick, 2_000)
    {:noreply, 0}
  end

  def handle_info(:tick, state) do
    Logger.debug("Tick")
    for i <- 0..299 do
      r = :rand.uniform(255)
      g = :rand.uniform(255)
      b = :rand.uniform(255)
      Blinkchain.set_pixel(%Point{x: i, y: 0}, %Color{r: r, g: g, b: b, w: 255})
    end

    try  do
      Blinkchain.render()
    rescue
      _ -> IO.puts "oops"
    end

    Process.send_after(self(), :tick, 1_000)
    {:noreply, state + 1}
  end
end
