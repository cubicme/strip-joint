defmodule StripJoint.Modes.Manual do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    IO.puts "Manual Init"
    {:ok, 0}
  end

  # GenServer callbacks

  def handle_call({:set, index, color}, _caller, state) do
    Blinkchain.set_pixel({index, 0}, color)
    render()
    {:reply, :ok, state}
  end

  def handle_call({:off, index}, _caller, state) do
    Blinkchain.set_pixel({index, 0}, {0, 0, 0, 0})
    render()
    {:reply, :ok, state}
  end

  defp render() do
    try  do
      Blinkchain.render()
    rescue
      e -> IO.puts "oops rendering"
    end
  end
end
