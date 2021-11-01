defmodule StripJointDoorWeb.Router do
  use StripJointDoorWeb, :router


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StripJointDoorWeb do
    pipe_through :api
    get "/", HomeController, :index
    delete "/modes", ModesController, :kill
    post "/modes", ModesController, :start
    post "/modes/set/:index", ModesController, :set
    delete "/modes/set/:index", ModesController, :off
    delete "/modes/set", ModesController, :off
    post "/modes/brightness", ModesController, :brightness
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: StripJointDoorWeb.Telemetry
    end
  end
end
