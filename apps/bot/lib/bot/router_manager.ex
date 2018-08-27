defmodule Bot.RouterManager do
  alias Nostrum.Api
  use Agent
  alias Bot.{Consumer}

  @allow_flags [
    "help",
    "records",
    "clean"
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
        prefix = hd(fill_invocation)
        args = tl(fill_invocation)

        cond do
          # 指令路由
          Enum.member?(@allow_flags, prefix) ->
            routing_msg(prefix, args, msg)

          # 未知指令
          true ->
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
end
