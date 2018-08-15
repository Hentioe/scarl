defmodule Pubg.Records.QueryModel do
  @moduledoc false

  @id_cache_table :user_id_cache
  def init_table do
    :ets.new(@id_cache_table, [:named_table, :public])
  end

  defp cache_user_id(username, user_id) do
    :ets.insert(@id_cache_table, {username, user_id})
  end

  defp lookup_user_id_by_cache(username) do
    case :ets.lookup(@id_cache_table, username) do
      [{^username, user_id}] -> {:ok, user_id}
      [] -> nil
    end
  end

  @default_server "as"
  defstruct [:username, :season, :server, :mode, :queue_size, :queue_name]

  def create(props) do
    username = Keyword.get(props, :username, "shroud")
    username = String.trim(username)

    season = Keyword.get(props, :season, default_season())

    server = Keyword.get(props, :server, @default_server)

    queue_size = Keyword.get(props, :queue_size)
    mode = Keyword.get(props, :mode)

    queue_name =
      case queue_size do
        1 -> "SOLO"
        2 -> "DUO"
        4 -> "SQUAD"
        _ -> "UNKNOWN"
      end

    %__MODULE__{
      username: username,
      season: season,
      server: server,
      mode: mode,
      queue_size: queue_size,
      queue_name: queue_name
    }
  end

  def default_season do
    "2018-08"
  end

  def gen_user_id(model) do
    url = "https://pubg.op.gg/user/#{model.username}"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(url, [], follow_redirect: true) do
      id =
        body
        |> Floki.find("#userNickname")
        |> Floki.attribute("data-user_id")

      if length(id) > 0, do: {:ok, hd(id)}, else: {:error, :not_found}
    else
      error -> error
    end
  end

  def to_string(
        %{username: username, season: season, mode: mode, queue_size: queue_size, server: server} =
          model
      ) do
    with {:ok, user_id} <- lookup_user_id_by_cache(username) || gen_user_id(model) do
      url =
        "https://pubg.op.gg/api/users/#{user_id}/ranked-stats?season=#{season}&server=pc-#{server}&queue_size=#{
          queue_size
        }&mode=#{mode}"

      # 缓存用户 ID（避免重复查询）
      cache_user_id(username, user_id)
      {:ok, url}
    else
      error -> error
    end
  end
end
