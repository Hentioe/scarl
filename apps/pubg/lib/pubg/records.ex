defmodule Pubg.Records do
  @moduledoc """
  PUBG 战绩数据相关模块
  """

  alias Pubg.Records.{QueryModel, Struct}

  def query(query_model) do
    with {:ok, url} <- QueryModel.to_string(query_model),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Poison.decode(body) do
      records = Struct.create(data["stats"], data["grade"])
      {:ok, records}
    else
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "No records"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      error ->
        error
    end
  end
end
