defmodule Pubg.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Pubg.Records.QueryModel.init_table()
    {:ok, self()}
  end
end
