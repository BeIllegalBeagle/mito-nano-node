defmodule MitoNode.Client do
  use WebSockex

  def start_link(state) do
    WebSockex.start_link("ws://localhost:7078", __MODULE__, state, [name: MitoNano])
  end

  def start_mongo() do
    {:ok, cn} = Mongo.start_link(name: MitoMongo, url: "mongodb://localhost:27017/mqttCollection")
  end

  def all_users() do
    Mongo.aggregate(MitoMongo, "mqttUsers", [], limit: 20, pool: DBConnection.Poolboy)
    |> Enum.to_list()
  end

  defp all_users_accounts() do
    case all_users() do
      [] ->
        ["nano_1qzfp3op48im348qdybmrheu9dogtopj1jyioguq9pyo5i7mkqgo4jaswp4a"]
      users ->
        users |> Enum.flat_map(fn x -> x["accounts"] end)
        |> Enum.uniq
    end
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

  def socket_resubs() do

    {:ok, unmessage} = %{
      "action" => "unsubscribe",
      "topic" => "confirmation"
    } |> Jason.encode

    {:ok, message} = %{
      "action" => "subscribe",
      "topic" => "confirmation",
      "options" => %{
        "all_local_accounts" => false,
        "accounts" => all_users_accounts()
      }
    } |> Jason.encode


    with :ok <- WebSockex.send_frame(MitoNano, {:text, unmessage}),
      :ok <- WebSockex.send_frame(MitoNano, {:text, message})
      do
        :ok
    else
      {:error, map} ->
        {:error, map}
    end

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

   {:ok, block_message} = Jason.decode(frame)

  %{"message" => block} = block_message
  %{"block" => %{"subtype" => block_type, "link_as_account" => recieving_account}} = block

  is_send = if block_type == "send", do: true, else: false

  block = block
    |> Map.put("is_send", is_send)
    |> Map.delete("confirmation_type")


   IO.inspect("decoded stuff")
   IO.inspect(block)

   IO.inspect(recieving_account)
   recieent = all_users() |> Enum.filter(fn user -> Enum.member?(user["accounts"], recieving_account) end)
   IO.inspect recieent
   if recieent == [] do
     ##do nothing
   else
     Enum.each(recieent, fn user -> publish_recieve_nofication(user["wallet"], block) end)
   end

   {:ok, state}
 end

 def publish_recieve_nofication(wallet, block) do
   IO.inspect "pubbing for wallet #{wallet}"
  {:ok, msg} = Jason.encode(block)

  case Tortoise.publish_sync(MitoNodeMQTT, "wallet/#{wallet}/block/state", msg, qos: 2, timeout: 2000) do
    :ok ->
      :done
    {:error, :timeout} ->
      __MODULE__.publish_recieve_nofication(wallet, block)
    {:error, :canceled} ->
      __MODULE__.publish_recieve_nofication(wallet, block)
  end
end

end
