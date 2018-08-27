defmodule Bot.Application do
  @moduledoc """
  Bot 回调入口
  """
  use Application
  alias Bot.{RouterManager}
  alias Bot.Router.{HelpRouter, RecordsRouter, CleanRouter}

  def start(_type, _args) do
    case Bot.Supervisor.start_link() do
      {:ok, pid} ->
        RouterManager.add_router(HelpRouter)
        RouterManager.add_router(RecordsRouter)
        RouterManager.add_router(CleanRouter)
        {:ok, pid}

      error ->
        {:error, error}
    end
  end
end
