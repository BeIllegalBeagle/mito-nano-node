defmodule MitoNode do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [

      supervisor(MitoNode.Endpoint, []),
      Tortoise.Supervisor.child_spec([strategy: :one_for_one, name: BlockListener]),
      worker(Mongo, [[name: :mongo, database: "mqttCollection", pool: DBConnection.Poolboy]]),
      # {MitoNode.Client, ["random WebSockex message"]}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MitoNode.Endpoint.config_change(changed, removed)
    :ok
  end
end
