defmodule Bot.Consumer do
  @moduledoc """
  Bot 消费消息
  """
  use Nostrum.Consumer
  use Bot.{FlagRouter}
  alias Nostrum.Api
  import Nostrum.Struct.Embed
  alias Pubg.Records.{QueryModel}

  def start_link do
    Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  @default_server "as"
  @default_mode "tpp"
  def handle_flag(:records, args, msg) do
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

      title = "#{query.season} #{query.mode}-#{query.queue_size}"

      content =
        if is_map(records) do
          "
**评　　分**：#{records.rating}\n
**评　　级**：#{records.grade}\n
**　　K/D**：#{records.kda}\n
**匹配次数**：#{records.matches_cnt}\n
**前十次数**：#{records.topten_matches_cnt}\n
**吃鸡次数**：#{records.win_matches_cnt}\n
**击杀总数**：#{records.kills_sum}\n
**助攻次数**：#{records.assists_sum}\n
**爆头几率**：#{records.headshot_ratio}%\n
**均场伤害**：#{records.damage_dealt_avg}\n
**最多击杀**：#{records.kills_max}\n
**生存时间**：#{records.time_survived_avg}\n
**平均排名**：\##{records.rank_avg}
          "
          |> String.replace("\n\n", "\n")
          |> String.trim()
        else
          records
        end

      [title, content]
    end

    put_field = fn embed, [title, content] ->
      put_field(embed, title, content)
    end

    fields = [1, 2, 4] |> Enum.map(gen_field)

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title(":frog: #{username} 战绩(#{server})")
      |> put_color(6_271_715)
      |> put_field.(Enum.at(fields, 0))
      |> put_field.(Enum.at(fields, 1))
      |> put_field.(Enum.at(fields, 2))

    Api.create_message(msg.channel_id, embed: embed)
  end

  def handle_flag(:help, _args, msg) do
    Api.create_message(msg.channel_id, "我是一条帮助消息")
  end

  def handle_onlyat(msg) do
    handle_flag(:help, [], msg)
  end

  def handle_unknown_flag(flag, _args, msg) do
    Api.create_message(msg.channel_id, "无法理解的指令: #{flag}")
  end

  def handle_flag(_) do
    nil
  end

  @scar_binary ".scar"
  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    case msg.content do
      <<@scar_binary, 32, data::binary>> ->
        routing_in_message(data, msg)

      <<@scar_binary>> ->
        handle_onlyat(msg)

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
