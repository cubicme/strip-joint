defmodule StripJointDoorWeb.ModesController do
  use StripJointDoorWeb, :controller

  def kill(conn, _params) do
    broadcast :kill_current
    send_resp(conn, 200, "sent")
  end

  def start(conn, %{"mode" => mode}) do
    broadcast {:start, String.to_existing_atom("Elixir.StripJoint.Modes.#{Macro.camelize(mode)}")}
    send_resp(conn, 200, "sent")
  end

  def off(conn, %{"index" => index}) do
    broadcast {:cmd, {:off, String.to_integer(index)}}
    send_resp(conn, 200, "sent")
  end

  def off(conn, _params) do
    broadcast {:cmd, {:off}}
    send_resp(conn, 200, "sent")
  end

  def set(conn, %{"index" => index, "color" => color}) do
    command {:set, String.to_integer(index), color}
    send_resp(conn, 200, "sent")
  end

  def program(conn, %{"sequence" => sequence} = params) do
    command {:program, sequence, params["step_time"] || 1000}
    send_resp(conn, 200, "sent")
  end

  def brightness(conn, %{"value" => value}) do
    command {:brightness, String.to_integer(value)}
    send_resp(conn, 200, "sent")
  end

  defp broadcast(args) do
    IO.inspect args
    Phoenix.PubSub.broadcast(StripJoint.PubSub, "modes", args)
  end

  defp command(args) do
    Phoenix.PubSub.broadcast(StripJoint.PubSub, "modes", {:cmd, args})
  end
end
