defmodule MitoNode.Mqtt do

  def make_wallet(wallet_name) do
        cursor = Mongo.find(:mongo, "mqttUsers", %{"$and" => [%{wallet: wallet_name}]},
     limit: 20, pool: DBConnection.Poolboy)

    cursor = cursor
    |> Enum.to_list()

    with cursor != [] do

      wallet_info = %{"wallet" => wallet_name,
        "accounts" => []}

       {:ok, _bson} = Mongo.insert_one(:mongo, "mqttUsers", wallet_info, pool: DBConnection.Poolboy)
       %{"success" => true}
    else
      false ->
        %{"error" => "choose different wallet ID"}
    end

  end

  def add_accounts(wallet, accounts) do

    cursor = Mongo.find(:mongo, "mqttUsers", %{"$and" => [%{wallet: wallet}]},
    limit: 20, pool: DBConnection.Poolboy) |> Enum.to_list()

    with cursor != [] do

      [wallet_acc] = cursor

     {:ok, _new_meesages_map} = Mongo.update_one(:mongo, "mqttUsers",
                 %{"wallet": wallet},
                 %{"$set": %{"accounts": accounts ++ wallet_acc["accounts"]}},
                  pool: DBConnection.Poolboy)
     else
       false ->
         %{"error" => "wallet Id not found"}
     end


  end

end