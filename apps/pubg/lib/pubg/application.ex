defmodule Pubg.Application do
  use Application

  def start(_type, _args) do
    Pubg.Records.QueryModel.init_table()
    {:ok, self()}
  end
end
