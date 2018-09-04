defmodule Storage do
  @moduledoc """
  数据持久化模块
  """
  alias Storage.Repo
  alias Storage.Repo.{Welcome}

  import Ecto.Query

  def set_welcome(welcome) do
    welcome = %{welcome | id: nil, enabled: true}

    case find_welcome(welcome.server_id) do
      nil ->
        Repo.insert(welcome)

      w ->
        changed_welcome =
          Ecto.Changeset.change(
            %Welcome{id: w.id},
            channel_id: welcome.channel_id,
            operator: welcome.operator,
            tpl_text: welcome.tpl_text
          )

        Repo.update(changed_welcome)
    end
  end

  def find_welcome(server_id) do
    query =
      from w in Welcome,
        where: w.server_id == ^server_id,
        select: w

    Repo.one(query)
  end

  def find_welcome(server_id, channel_id) do
    query =
      from w in Welcome,
        where: w.server_id == ^server_id and w.channel_id == ^channel_id,
        select: w

    Repo.one(query)
  end
end
