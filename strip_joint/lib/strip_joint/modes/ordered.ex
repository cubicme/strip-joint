defmodule StripJoint.Modes.Ordered do
  alias StripJoint.Modes.Auto
  use GenServer
  require Logger
  import LED

  defstruct step: 0, sequence: [], step_time: 1_000, timer: nil, current: []

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info "Ordered Init"

    sequence =
      StripJoint.Models.LED.set(:high_camera_polished)
      |> Enum.sort(fn (a, b) -> a.y >= b.y end)
      |> Enum.map(&(elem(&1.index, 1)))
      |> Enum.reduce([], fn e,a -> a ++ [[e] ++ Enum.uniq(List.flatten(a))] end)
    Process.send_after(self(), :step, 10)
    {:ok, %Auto{ sequence: sequence, step_time: 10}}
  end

  # Timer
  def handle_info(:step, %Auto{sequence: sequence, step: step, current: current, step_time: step_time} = state) do
    Logger.info("Ordered tick")
    new_leds = Enum.at(sequence, rem(step, length(sequence)))

    LED.set_list(current -- new_leds, "#00000000")
    LED.set_list(new_leds -- current, LED.rcolor())
    LED.render()

    Process.send_after(self(), :step, step_time)
    {:noreply, %{state | step: step + 1, current: new_leds}}
  end
end
