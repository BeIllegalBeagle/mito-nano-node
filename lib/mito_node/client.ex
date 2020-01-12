defmodule MitoNode.Client do
  use WebSockex

  def start_link(state) do
    WebSockex.start_link("ws://localhost:7078", __MODULE__, state)
  end

  def sub() do

    {:ok, message} = %{
    "action" => "subscribe",
    "topic" => "confirmation",
    "options" => %{
      "all_local_accounts" => true,
      "accounts" => [
        "nano_1qzfp3op48im348qdybmrheu9dogtopj1jyioguq9pyo5i7mkqgo4jaswp4a"
      ]
    }
  } |> Jason.encode

    IO.inspect(message)

    WebSockex.cast(__MODULE__, message)
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

 def handle_frame({:binary, frame}, state) do
   IO.inspect "Received frame"
   {:ok, state}
 end

end
