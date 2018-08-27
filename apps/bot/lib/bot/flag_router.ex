defmodule Bot.FlagRouter do
  defmacro __using__(_opts) do
    quote do
      @behaviour Bot.FlagRouter
      import Bot.FlagRouter

      def get_flag_prefix, do: init_flag()
      def init_flag, do: :default

      defoverridable init_flag: 0
    end
  end

  defmacro init_flag(prefix) do
    quote do
      def init_flag, do: unquote(prefix)
    end
  end

  @callback handle_flag(msg :: String.t(), msg :: term) :: :ok
end
