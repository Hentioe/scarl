defmodule Bot.Router.RecordsRouter do
  @moduledoc """
  Bot records 指令路由器
  """
  alias Nostrum.Api
  import Nostrum.Struct.Embed
  use Bot.FlagRouter
  alias Bot.{Consumer}
  alias Pubg.Records.{QueryModel}

  init_flag(:records)

  @default_server "as"
  @default_mode "tpp"
  def handle_flag(args, msg) do
    [username, mode, server] =
      case args do
        [username, mode, server] -> [username, mode, server]
        [username, mode] -> [username, mode, @default_server]
        [username] -> [username, @default_mode, @default_server]
        [] -> [msg.author.username, @default_mode, @default_server]
      end

    gen_field = fn queue_size ->
      query =
        QueryModel.create(username: username, queue_size: queue_size, mode: mode, server: server)

      records =
        case Pubg.records(query) do
          {:ok, records} -> records
          {:error, reason} -> reason
        end

      title = "#{query.season} #{String.upcase(query.mode)}-#{query.queue_name}"

      content =
        if is_map(records) do
          Pubg.Records.Struct.gen_records(records)
        else
          records
        end

      [title, content]
    end

    put_field = fn embed, [title, content] ->
      put_field(embed, title, content, true)
    end

    fields = [1, 2, 4] |> Enum.map(gen_field)

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title(":frog: #{username} 战绩 (#{String.upcase(server)})")
      |> put_color(6_271_715)
      |> put_field.(Enum.at(fields, 0))
      |> put_field.(Enum.at(fields, 1))
      |> put_field.(Enum.at(fields, 2))
      |> put_footer("注意：可能存在更新延迟。\t来源: pubg.op.gg", Consumer.gen_avatar_url(msg.author))

    Api.create_message(msg.channel_id, embed: embed)
  end
end
