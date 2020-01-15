defmodule MitoNode.Mqtt do

  def make_wallet(wallet_name) do
        cursor = Mongo.find(MitoMongo, "mqttUsers", %{"$and" => [%{wallet: wallet_name}]},
     limit: 20, pool: DBConnection.Poolboy)

    cursor = cursor
    |> Enum.to_list()

    with cursor != [] do

      wallet_info = %{"wallet" => wallet_name,
        "accounts" => []}

       {:ok, _bson} = Mongo.insert_one(MitoMongo, "mqttUsers", wallet_info, pool: DBConnection.Poolboy)
       %{"success" => true}
    else
      false ->
        %{"error" => "choose different wallet ID"}
    end

  end

  def add_accounts(wallet, accounts) do

    cursor = Mongo.find(MitoMongo, "mqttUsers", %{"$and" => [%{wallet: wallet}]},
    limit: 20, pool: DBConnection.Poolboy) |> Enum.to_list()

    with cursor != [] do

      IO.inspect cursor
      wallet_acc = cursor |> List.first

     {:ok, _new_meesages_map} = Mongo.update_one(MitoMongo, "mqttUsers",
                 %{"wallet": wallet},
                 %{"$set": %{"accounts": accounts ++ wallet_acc["accounts"]}},
                  pool: DBConnection.Poolboy)

      MitoNode.Client.socket_resubs()

     else
       false ->
         %{"error" => "wallet Id not found"}
     end


  end

end
