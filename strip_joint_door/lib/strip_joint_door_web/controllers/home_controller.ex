defmodule StripJointDoorWeb.HomeController do
  use StripJointDoorWeb, :controller

  def index(conn, _params) do
    text(conn, "Hello!")
  end
end
