defmodule Bot.Consumer do
  @moduledoc """
  Bot 消费消息
  """
  use Nostrum.Consumer
  use Bot.{FlagRouter}
  alias Bot.{ConfigModel}
  alias Nostrum.Api
  import Nostrum.Struct.Embed
  alias Pubg.Records.{QueryModel}

  @author_id "379265518907162637"

  def start_link do
    init_table(ConfigModel.read_by_env())
    started = Consumer.start_link(__MODULE__, name: __MODULE__)
    Api.update_status(:online, " #{get_game_status()}")
    started
  end

  @config_table :bot_config
  def init_table(config) do
    :ets.new(@config_table, [:named_table, :public])

    :ets.insert(
      @config_table,
      {:prefix_name, [config.prefix_name, byte_size(config.prefix_name)]}
    )

    :ets.insert(
      @config_table,
      {:invoke_mark, [config.invoke_mark, byte_size(config.invoke_mark)]}
    )

    :ets.insert(@config_table, {:game_status, config.game_status})
    :ets.insert(@config_table, {:args_split, config.args_split})
  end

  def get_config_item(key) do
    case :ets.lookup(@config_table, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  def get_prefix_name, do: get_config_item(:prefix_name)
  def get_invoke_mark, do: get_config_item(:invoke_mark)
  def get_args_split, do: get_config_item(:args_split)
  def get_game_status, do: get_config_item(:game_status)

  def handle_flag(:help, args, msg) do
    message =
      if length(args) > 0 do
        gen_func_help_msg(hd(args))
      else
        title = "欢迎使用 SCAR-L 机器人，这里是帮助信息"
        [prefix_name, _] = get_prefix_name()
        [invoke_mark, _] = get_invoke_mark()
        prefix_invoke = "#{prefix_name}#{invoke_mark}"

        gen_info_field = fn embed ->
          content = "
** 程序版本 **: alpha
** 上次重启 **: 2018-10-10:12:00:01　
          "
          put_field(embed, "运行时", content <> "\n")
        end

        gen_feature_field = fn embed ->
          content = "
** #{prefix_invoke}welcome ** (进服通知)
** #{prefix_invoke}clean** (消息清理)
** #{prefix_invoke}records** (战绩查询)
** #{prefix_invoke}help** (功能帮助)
        "

          put_field(embed, "功能列表", content <> "\n")
        end

        gen_opensource_field = fn embed ->
          content = "
** 作者 **: Hentioe_Cl#0120
** 代码 **: https://github.com/Hentioe/scarl
** 许可 **: MIT
"
          put_field(embed, "开源信息", content <> "\n")
        end

        embed =
          %Nostrum.Struct.Embed{}
          |> put_title(title)
          |> put_color(6_271_715)
          |> gen_info_field.()
          |> gen_feature_field.()
          |> gen_opensource_field.()
          |> put_footer("您可以使用 '#{prefix_invoke}help [功能名称]' 查看具体功能的详细用法以及指令示例", gen_avatar_url(msg.author))

        [embed: embed]
      end

    Api.create_message(msg.channel_id, message)
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
      |> put_footer("注意：可能存在更新延迟。\t来源: pubg.op.gg", gen_avatar_url(msg.author))

    Api.create_message(msg.channel_id, embed: embed)
  end

  def handle_flag(:clean, args, msg) do
    cond do
      Integer.to_string(msg.author.id) != @author_id ->
        Api.create_message(msg.channel_id, "您没有权限使用删除指令，因为它的风险很高。")

      length(args) == 2 ->
        [user, limit] = args
        limit = String.to_integer(limit)

        user_match =
          (fn ->
             rs = Regex.scan(~r/<@(\d+)>/, user)

             if length(rs) > 0 do
               [[_, id]] = rs
               {:id, id}
             else
               [[_, nickname, discriminator]] = Regex.scan(~r/@([^#]+)#(\d+)/, user)

               {:username_discriminator, nickname, discriminator}
             end
           end).()

        mached_msg_author? = fn user_msg ->
          case user_match do
            {:id, id} ->
              Integer.to_string(user_msg.author.id) == id

            {:username_discriminator, username, discriminator} ->
              user_msg.author.username == username &&
                user_msg.author.discriminator == discriminator
          end
        end

        if_same_id_execute_delete = fn user_msg ->
          if mached_msg_author?.(user_msg) do
            Api.delete_message(user_msg)
          else
            :ignore
          end
        end

        {:ok, msg_list} = Api.get_channel_messages(msg.channel_id, limit + 1)

        gen_response_result = fn results ->
          executed_count = Enum.count(results, &(&1 != :ignore))
          deleted_count = Enum.count(results, &(&1 == {:ok}))
          error_count = Enum.count(results, &([&1][:error] != nil))

          resp_content =
            "扫描 #{length(results)} 条消息，执行删除 #{executed_count} 条消息，实际删除 #{deleted_count} 条消息，删除失败 #{
              error_count
            } 条。"

          resp_content =
            if error_count > 0,
              do: resp_content <> "（出现删除失败可能是网络问题，建议再次输入删除指令清空没删掉的消息）",
              else: resp_content

          resp_content
        end

        msg_content =
          msg_list
          |> Enum.map(if_same_id_execute_delete)
          |> gen_response_result.()

        Api.create_message(msg.channel_id, msg_content)

      true ->
        Api.create_message(msg.channel_id, "您输入的参数不正确！")
    end

    :ignore
  end

  def gen_avatar_url(user, size \\ 64) do
    "#{Nostrum.Struct.User.avatar_url(user)}?size=#{size}"
  end

  def gen_func_help_msg(func_name) do
    case func_name do
      "welcome" ->
        "
`welcome` 功能的目的是为每一个进服的小伙伴发去一个附带@的欢迎消息，还可以用于向新人阐述服务器规则。
        "
        |> String.trim()

      "records" ->
        "
`records` 指令用于查询 PUBG 战绩，它按顺序支持三个参数（可都省略，有默认值）：
```
1. 用户名，无大小写区分，默认值：Discord 昵称
2. 游戏模式，fpp/tpp，默认值：tpp
3. 服务器，as/sea/na，默认值：as
```
指令结构：`scar.records [用户名] [游戏模式] [服务器]`，举例：`scar.records shroud fpp na`
        "
        |> String.trim()

      "help" ->
        "使用 help 功能查询 help 的用法是无效的，请直接使用 `scar` 指令"

      _ ->
        "您要咨询的 #{func_name} 功能无效，是不是输入错了？"
    end
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

  @welcome_channel_id 425_199_707_829_043_201
  def handle_no_routed_msg(msg) do
    if msg.channel_id == @welcome_channel_id do
      welcome(msg)
    else
      :ignore
    end
  end

  def welcome(msg) do
    {:ok, client} = Api.get_current_user()

    if msg.author.id == client.id do
      :ignore
    else
      welcome(msg, client)
    end
  end

  @chat_channel_id "379541650290245634"
  def welcome(msg, client) do
    msg_content =
      if msg.content == "" do
        "
热烈欢迎新人 <@#{msg.author.id}> 来到这里！我是由 <@#{@author_id}> 所开发的
专属此服务器的机器人<#{client.username}>，
记得转到 <\##{@chat_channel_id}> 跟大家交流哦～
  "
        |> String.trim()
      else
        "<@#{msg.author.id}> 记得转到 <\##{@chat_channel_id}> 跟大家交流哦～"
      end

    Api.create_message(msg.channel_id, msg_content)
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    [prefix_name, prefix_name_size] = get_prefix_name()
    [invoke_mark, invoke_mark_size] = get_invoke_mark()

    routed =
      case msg.content do
        <<^prefix_name::binary-size(prefix_name_size),
          ^invoke_mark::binary-size(invoke_mark_size), data::binary>> ->
          routing_in_message(data, msg)

        <<^prefix_name::binary-size(prefix_name_size)>> ->
          handle_onlyat(msg)

        _ ->
          :no_routing
      end

    if routed == :no_routing do
      handle_no_routed_msg(msg)
    else
      routed
    end
  end

  def handle_event(_event) do
    :noop
  end
end
