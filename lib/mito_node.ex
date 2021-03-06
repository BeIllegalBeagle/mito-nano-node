defmodule MitoNode do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(MitoNode.Endpoint, []),
      Tortoise.Supervisor.child_spec([strategy: :one_for_one, name: BlockListener]),
      worker(Mongo, [[name: :mongo, pool: DBConnection.Poolboy, url: "mongodb://localhost:27017/mqttCollection"]]),
      {MitoNode.Client, ["random WebSockex message"]}
    ]

    opts = [strategy: :one_for_one]
    setup_bridge()
    with {:ok, pid} <- Supervisor.start_link(children, opts),
         {:ok, _pid} <- MitoNode.Client.start_mongo,
          :ok <- MitoNode.Client.socket_subs do
      {:ok, pid}
    else
      {:error, reason} ->
        IO.inspect(reason)
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MitoNode.Endpoint.config_change(changed, removed)
    :ok
  end

  def setup_bridge() do
    nano_node_mqtt_start()
  end

  def nano_node_mqtt_start() do

    Tortoise.Supervisor.start_child(
      client_id: MitoNodeMQTT,
      handler: {MitoNode.Mqtt.Handler, []},
      keep_alive: 30000,
      server: {Tortoise.Transport.Tcp, host: '127.0.0.1', port: 1883},##mito location
      subscriptions: [{"wallet/+/register", 2}]
    )

  end

end
