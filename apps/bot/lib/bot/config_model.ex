defmodule Bot.ConfigModel do
  @moduledoc """
  Bot 配置模型
  """
  @default_prefix_name "scar"
  @default_invoke_mark "."
  @default_args_split " "

  defstruct [:prefix_name, :invoke_mark, :args_split]

  defp get_item_by_bot_config(key, default) do
    Application.get_env(:bot, key, default)
  end

  def read_by_env do
    prefix_name = get_item_by_bot_config(:prefix_name, @default_prefix_name)
    invoke_mark = get_item_by_bot_config(:invoke_mark, @default_invoke_mark)
    args_split = get_item_by_bot_config(:args_split, @default_args_split)

    %__MODULE__{
      prefix_name: prefix_name,
      invoke_mark: invoke_mark,
      args_split: args_split
    }
  end
end
