# TODO change to state machine
defmodule StripJoint.Modes.Calibration do
  import LED
  require Logger
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info "Calibration Init"
    off()
    render()
    Blinkchain.set_brightness(0, 5)
    {:ok, %{current_index: 35, set: :none}}
  end

  def start() do
  end

  def handle_call({:start, set_name}, _caller, state) do
    GenServer.cast(self(), :next)
    {:reply, :ok, %{state | set: set_name}}
  end

  def handle_call({:submit, {x, y}}, _caller, %{current_index: index, set: set} = state) do
    StripJoint.Models.LED.update(index, x, y, set)
    Logger.info("Updated \##{index}, to #{x}, #{y}")
    set(index, "#00000000")

    next_index = index + 1
    if next_index < 600 do
      GenServer.cast(self(), :next)
      {:reply, :ok, %{state | current_index: next_index}}
    else
      GenServer.cast(self(), :finish)
      {:reply, :ok, %{state | current_index: index}}
    end
  end

  def handle_cast(:finish, state) do
    Logger.info("FINISHED")
    StripJointDoorWeb.Endpoint.broadcast!("calibration:lobby", "finish", %{})
    {:noreply, state}
  end

  def handle_cast(:next, %{current_index: index} = state) do
    Logger.info("NEXT")
    set(index, "#FFFFFFFF")
    render()
    StripJointDoorWeb.Endpoint.broadcast!("calibration:lobby", "request_coors", %{})
    {:noreply, state}
  end
end
