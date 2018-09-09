defmodule Bot.RouterManager do
  @moduledoc """
  Bot 指令消息路由管理器
  """
  use Agent

  alias Nostrum.Api
  alias Bot.{Consumer}
  alias Nostrum.Struct.{User}

  @allow_flags [
    "help",
    "records",
    "clean",
    "welcome"
  ]
  @author_id "379265518907162637"

  def start_link(_otps) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add_router(router) do
    Agent.update(__MODULE__, fn router_list -> [router | router_list] end)
  end

  def get_router_list do
    Agent.get(__MODULE__, fn router_list -> router_list end)
  end

  def route_message(msg) do
    [prefix_name, prefix_name_size] = Consumer.get_prefix_name()
    [invoke_mark, invoke_mark_size] = Consumer.get_invoke_mark()
    args_split = Consumer.get_args_split()

    case msg.content do
      <<^prefix_name::binary-size(prefix_name_size), ^invoke_mark::binary-size(invoke_mark_size),
        data::binary>> ->
        fill_invocation = String.split(data, args_split)

        fill_invocation =
          fill_invocation
          |> Enum.filter(fn arg -> arg != "" end)

        prefix = hd(fill_invocation)
        args = tl(fill_invocation)

        if Enum.member?(@allow_flags, prefix) do
          # 路由指令
          routing_msg(prefix, args, msg)
        else
          # 未知指令
          handle_unknown_flag(prefix, args, msg)
        end

      <<^prefix_name::binary-size(prefix_name_size)>> ->
        handle_onlyat(msg)

      _ ->
        handle_no_routed_msg(msg)
    end
  end

  def routing_msg(prefix, args, msg) do
    router_list = get_router_list()

    router_list
    |> Enum.each(fn router ->
      custom_prefix = router.get_flag_prefix()
      if custom_prefix == String.to_atom(prefix), do: router.handle_flag(args, msg)
    end)
  end

  def handle_onlyat(msg) do
    routing_msg("help", [], msg)
  end

  def handle_unknown_flag(prefix, _args, msg) do
    Api.create_message(msg.channel_id, "无法理解的指令: #{prefix}")
  end

  def handle_no_routed_msg(msg) do
    case Storage.find_welcome(msg.guild_id, msg.channel_id) do
      nil -> :ignore
      w -> welcome(msg, w)
    end
  end

  def welcome(msg, w) do
    {:ok, client} = Api.get_current_user()

    if msg.author.id == client.id do
      :ignore
    else
      welcome(msg, w, client)
    end
  end

  @chat_channel_id "379541650290245634"
  def welcome(msg, w, client) do
    msg_content =
      if msg.content == "" do
        tpl_text = w.tpl_text <> "记得转到 <\##{@chat_channel_id}> 跟大家交流哦～"

        tpl_text
        |> String.replace("^at_user^", "#{msg.author |> User.mention()}")
        |> String.replace("^at_author^", "#{%User{id: @author_id} |> User.mention()}")
        |> String.replace("^bot_name^", "#{client.username}")
        |> String.replace("^  ^", "\n")
        |> String.trim()
      else
        "<@#{msg.author.id}> 记得转到 <\##{@chat_channel_id}> 跟大家交流哦～"
      end

    Api.create_message(msg.channel_id, msg_content)
  end
end
