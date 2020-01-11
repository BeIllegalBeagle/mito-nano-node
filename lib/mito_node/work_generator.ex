defmodule MitoNode.WorkGenerator do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "127.0.0.1:7076"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON

  def genrate_work(hash) do

    {:ok, diff} = post("", %{action: "active_difficulty"})

    %{"network_current" => diffivluty} = diff.body

    {:ok, response} = post("", %{action: "work_generate", hash: "#{hash}", difficulty: diffivluty})

    IO.inspect response.body
    {:ok, response.body}

    %{"work" => work} = response.body
  end

end
