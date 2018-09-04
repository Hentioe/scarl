defmodule Storage.Supervisor do
  use Supervisor
  alias Storage.{Repo}

  def start_link do
    children = [
      Repo
    ]

    opts = [strategy: :one_for_one, name: Storage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
