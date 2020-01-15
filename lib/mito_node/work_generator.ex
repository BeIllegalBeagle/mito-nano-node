defmodule MitoNode.WorkGenerator do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://[::0]:7076"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON

  def genrate_work(hash) do

    # {:ok, diff} = post("", %{action: "active_difficulty"})
    # %{"network_current" => diffivluty} = diff.body

    {:ok, opts} =  %{
    "action": "active_difficulty",
    } |> Jason.encode

    {result, _invalid_number} = System.cmd("curl", ["-d", opts, "[::1]:7076"])
    {:ok, %{"network_current" => difficulty}} = Jason.decode(result)

    {:ok, work_opts} =  %{
    "action": "work_generate",
    "hash": hash,
    "difficulty": diffivluty
    } |> Jason.encode

    # {:ok, response} = post("", %{action: "work_generate", hash: "#{hash}", difficulty: diffivluty})

    {result, _invalid_number} = System.cmd("curl", ["-d", work_opts, "[::1]:7076"])
    with {:ok, %{"work" => work}} <- result |> Jason.decode do
      {:ok, %{"work" => work}}
    else
      {:error, message} ->
        {:error, message}
    end

    # IO.inspect response.body

    # {:ok, response.body}

    # %{"work" => work} = response.body
  end

end
