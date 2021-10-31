defmodule StripJoint.Modes.Ticker do
  use GenServer

  @impl
  def start_link(opts) do
    IO.puts "Start link Ticker"
    IO.inspect opts

    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    Process.send_after(self(), :tick, 1)
    {:ok, 0}
  end

  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, 1000)
    IO.puts "Tick \##{state}"
    {:noreply, state + 1}
  end
end
