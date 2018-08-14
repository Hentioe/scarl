defmodule Bot.Consumer do
  @moduledoc """
  Bot 消费消息
  """
  use Nostrum.Consumer
  use Bot.{FlagRouter}
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  def handle_flag(:records, _args, msg) do
    Api.create_message(msg.channel_id, "战绩查询")
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
