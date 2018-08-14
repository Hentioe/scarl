defmodule Pubg.RecordsTest do
  use ExUnit.Case
  import Pubg.Records
  alias Pubg.Records.QueryModel

  test "query" do
    query_model = QueryModel.create(username: "Hentioe_Cl", mode: "tpp", queue_size: 4)
    {:ok, _} = query(query_model)
  end
end
