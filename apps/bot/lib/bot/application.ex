defmodule Bot.Application do
  @moduledoc """
  Bot 回调入口
  """
  use Application

  def start(_type, _args) do
    case Bot.Supervisor.start_link() do
      {:ok, pid} -> {:ok, pid}
      error -> {:error, error}
    end
  end
end
