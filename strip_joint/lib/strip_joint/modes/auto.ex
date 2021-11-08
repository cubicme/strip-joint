defmodule StripJoint.Modes.Auto do
  alias __MODULE__
  use GenServer
  require Logger
  import LED

  defstruct step: 0, sequence: [], step_time: 1_000, timer: nil, current: []

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info "Auto Init"
    {:ok, {0}}
  end

  # GenServer callbacks
  def handle_call({:program, steps, step_time}, _caller, _state) do
    Process.send_after(self(), :step, 1)
    {:reply, :ok, %Auto{ sequence: steps, step_time: step_time}}
  end

  # Timer
  def handle_info(:step, %Auto{sequence: sequence, step: step, current: current, step_time: step_time} = state) do
    new_leds = Enum.at(sequence, rem(step, length(sequence)))

    LED.set_list(current -- new_leds, "#00000000")
    LED.set_list(new_leds -- current, LED.rcolor())
    LED.render()

    Process.send_after(self(), :step, step_time)
    {:noreply, %{state | step: step + 1, current: new_leds}}
  end


  # def handle_call({:set, index, clr}, _caller, state) do
  #   set(index, clr)
  #   Logger.info "#{index} to #{clr}"
  #   render()
  #   {:reply, :ok, state}
  # end

  # def handle_call({:off}, _caller, state) do
  #   fill(0, 244, "#00000000")
  #   render()
  #   {:reply, :ok, state}
  # end

  # def handle_call({:off, index}, _caller, state) do
  #   Logger.info "off \##{index}"
  #   Blinkchain.set_pixel({index, 0}, {0, 0, 0, 0})
  #   render()
  #   {:reply, :ok, state}
  # end

  # def handle_call({:brightness, value}, _caller, state) do
  #   Logger.info "brightness #{value}"
  #   Blinkchain.set_brightness(0, value)
  #   render()
  #   {:reply, :ok, state}
  # end

end
