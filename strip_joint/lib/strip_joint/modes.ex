defmodule StripJoint.Modes do
  alias Phoenix.PubSub

  use GenServer

  require Logger

  defstruct major: nil, minor: []

  @default_mode StripJoint.Blinker

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(initial_mode) do
    PubSub.subscribe(StripJoint.PubSub, "modes")
    {:ok, supervisor} = StripJoint.ModeSupervisor.start_link(strategy: :one_for_one, name: StripJoint.ModeSupervisor)
    child = initial_mode || @default_mode
    modes = start_major_mode(supervisor, %StripJoint.Modes{major: nil, minor: []}, child)
    {
      :ok,
      {supervisor, modes}
    }
  end

  def handle_info(:kill_current, {supervisor, %{major: major} = modes} = state) do
    Logger.info("Killing the current mode")
    new_modes = case major do
      nil -> modes
      {module, pid} -> kill_major(supervisor, modes)
    end
    {:noreply, {supervisor, new_modes}}
  end

  def handle_info({:start, module}, {supervisor, modes}) do
    new_modes = start_major_mode(supervisor, modes, module)
    {:noreply, {supervisor, new_modes}}
  end

  # {:cmd, {:set, 1, {255, 0, 0, 255}}}
  def handle_info({:cmd, args}, {_, %{major: nil}} = state) do
    Logger.warn("No mode is running to handle the command")
    {:noreply, state}
  end

  def handle_info({:cmd, args}, {_, %{major: {_, pid}} = modes} = state) do
    Logger.info("passing command to the current mode")
    GenServer.call(pid, args)
    {:noreply, state}
  end

  def handle_info(other_shit, state) do
    IO.puts "Modes can't handle the following shit:"
    IO.inspect other_shit
    {:noreply, state}
  end

  defp start_major_mode(supervisor, modes, mode) do
    {:ok, pid} = DynamicSupervisor.start_child(supervisor, {mode, name: mode})
    %StripJoint.Modes{modes | major: {mode, pid}}
  end

  defp kill_major(supervisor, %StripJoint.Modes{major: {module, pid}} = modes) do
    DynamicSupervisor.terminate_child(supervisor, pid)
    %StripJoint.Modes{modes | major: nil}
  end
end
