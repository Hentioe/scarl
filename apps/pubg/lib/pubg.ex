defmodule Pubg do
  @moduledoc """
  PUBG 开放 API 模块
  """

  def records(query_model) do
    Pubg.Records.query(query_model)
  end
end
