defmodule MitoNode.Client do
  use WebSockex

  def start_link(state) do
    WebSockex.start_link("ws://localhost:7078", __MODULE__, state, [name: MitoNano])
  end

  def all_users() do
    Mongo.aggregate(:mongo, "mqttUsers", [], limit: 20, pool: DBConnection.Poolboy)
    |> Enum.to_list()
  end

  defp all_users_accounts() do
    all_users()
    |> Enum.flat_map(fn x -> x["accounts"] end)
    |> Enum.uniq
  end

  def socket_subs() do

    {:ok, message} = %{
    "action" => "subscribe",
    "topic" => "confirmation",
    "options" => %{
      "all_local_accounts" => false,
      "accounts" => all_users_accounts()
    }
  } |> Jason.encode

    WebSockex.send_frame(MitoNano, {:text, message})

  end

  def handle_connect(conn, state) do
    IO.inspect("connected to the node!!!")
    {:ok, state}
  end

  def handle_cast(msg, state) do

    IO.inspect("new message from the node")
    IO.inspect(msg)
    {:ok, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
   # Logger.warn "websocket closing: #{inspect reason}"
   {:ok, state}
 end

 def handle_frame({:text, frame}, state) do
   IO.inspect "Received frame"
   IO.inspect frame

   {:ok, block_message} = Jason.decode(frame)

   %{"message" => block, "hash" => hash} = block_message
   %{"link_as_account" => recieving_account} = block

    recieent = all_users() |> Enum.find(fn user -> Enum.member(recieving_account, user["accounts"]) end)

    if recieent == [] do
      ##do nothing
    else
      Enum.each(recieent, fn user -> publish_recieve_nofication(user["wallet"], {recieving_account, hash}) end)
    end

   {:ok, state}
 end

 def publish_recieve_nofication(wallet, {account, hash}) do

  {:ok, msg} = Jason.encode(%{"account" => account, "hash" => hash})

  case Tortoise.publish_sync(MitoNodeMQTT, "wallet/#{wallet}/block/state", msg, qos: 2, timeout: 2000) do
    :ok ->
      :done
    {:error, :timeout} ->
      __MODULE__.publish_recieve_nofication(wallet, {account, hash})
    {:error, :canceled} ->
      __MODULE__.publish_recieve_nofication(wallet, {account, hash})
  end
end

end
