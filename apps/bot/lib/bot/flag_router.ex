defmodule Bot.FlagRouter do
  @moduledoc """
  Bot 消息指令路由
  """

  alias Nostrum.Struct.{Message}

  @type error :: {:error, Nostrum.Error.ApiError.t() | HTTPoison.Error.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Bot.FlagRouter

      @allow_flag_list [
        "help",
        "records",
        "clean"
      ]

      defp routing_in_message(data, msg) when is_binary(data) do
        [flag | args] = String.split(data, Bot.Consumer.get_args_split())

        cond do
          Enum.member?(@allow_flag_list, flag) ->
            handle_flag(String.to_atom(flag), args, msg)

          flag == "" ->
            handle_onlyat(msg)

          true ->
            handle_unknown_flag(flag, args, msg)
        end
      end

      def handle_flag(flag, args, _msg) do
        IO.puts("[默认指令处理函数] Flag: #{Atom.to_string(flag)}, args: #{List.to_string(args)}")
      end

      defoverridable handle_flag: 3
    end
  end

  @callback handle_flag(flag :: Atom.t(), args :: List.t(), msg :: term) ::
              error | {:ok, Message.t()}

  @callback handle_onlyat(msg :: term) :: error | {:ok, Message.t()}
  @callback handle_unknown_flag(flag :: String.t(), args :: List.t(), msg :: term) ::
              error | {:ok, Message.t()}
end
