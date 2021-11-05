defmodule StripJoint.Modes.Manual do
  use GenServer
  require Logger
  import LED

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info "Manual Init"
    {:ok, 0}
  end

  # GenServer callbacks

  def handle_call({:set, index, clr}, _caller, state) do
    set(index, clr)
    Logger.info "#{index} to #{clr}"
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
end
