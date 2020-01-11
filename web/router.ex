defmodule MitoNode.Router do
  use MitoNode.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MitoNode do
    pipe_through :api
    post "/genrate-work", UserController, :get_work

  end
end
