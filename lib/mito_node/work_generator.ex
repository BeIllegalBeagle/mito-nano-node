defmodule WorkGenerator do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://127.0.0.1:7076"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON

  def gnerate_work(hash) do
    {:ok, response} = post("", %{action: "work_generate", hash: "#{hash}"})
    IO.inspect response.body
    {:ok, response.body}
  end

end
