defmodule Bot.Supervisor do
  @moduledoc """
  Bot 监督树
  """
  use Supervisor
  alias Bot.{Consumer}

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Consumer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
