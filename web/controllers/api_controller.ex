defmodule MitoNode.APIController do
  use MitoNode.Web, :controller


@doc """

  returns proof of work for a block

  check if the requestors accounts is stored inside of mongo, reject if they arent in
"""

  def get_work(conn, %{"hash" => hash} = params) do
    IO.inspect(params)
    # params = with {%{"password" => password, "username" => username} = params}
    #   do
    #     Users.check_credentials(username, password)
    #   else
    #     {:error, reason} ->
    #       IO.inspect "ERROR"
    #     ##log this
    #   end

    {:ok, params} = MitoNode.WorkGenerator.genrate_work(hash)

    json conn |> put_status(:created), params

  end

  def register_wallet(conn, %{"wallet_name" => name} = params) do
    IO.inspect(params)

    params = MitoNode.Mqtt.make_wallet(name)

    json conn |> put_status(:created), params

  end

end
