defmodule StripJointDoorWeb.CalibrationChannel do
  require Logger
  use StripJointDoorWeb, :channel

  @impl true
  def join("calibration:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("start", payload, socket) do
    IO.puts "HANDLE START"
    Phoenix.PubSub.broadcast(StripJoint.PubSub, "modes", {:cmd, :start})
    {:noreply, socket}
  end

  def handle_in("submit", %{"x" => x, "y" => y}, socket) do
    IO.puts "HANDLE SUBMIT"
    Phoenix.PubSub.broadcast(StripJoint.PubSub, "modes", {:cmd, {:submit, {x, y}}} )

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
