defmodule Bot.Consumer do
  @moduledoc """
  Bot 消息消费方
  """
  use Nostrum.Consumer
  alias Bot.{RouterManager, ConfigModel}
  alias Nostrum.Api

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
    today = DateTime.utc_now()
    :ets.insert(@config_table, {:last_restart_date, "#{today.year}-#{today.month}-#{today.day}"})
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
  def get_last_restart_date, do: get_config_item(:last_restart_date)

  def gen_avatar_url(user, size \\ 64) do
    "#{Nostrum.Struct.User.avatar_url(user)}?size=#{size}"
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    RouterManager.route_message(msg)
  end

  def handle_event(_event) do
    :noop
  end
end
