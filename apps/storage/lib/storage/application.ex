defmodule Storage.Application do
  use Application
  alias Storage.{Supervisor}

  def start(_type, _args) do
    case Supervisor.start_link() do
      {:ok, pid} ->
        {:ok, pid}

      error ->
        error
    end
  end
end
