defmodule Bot.Application do
  use Application

  def start(_type, _args) do
    Bot.Consumer.start_link()
  end
end