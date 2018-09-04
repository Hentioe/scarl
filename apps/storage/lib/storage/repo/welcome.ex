defmodule Storage.Repo.Welcome do
  use Ecto.Schema

  schema "welcome" do
    # Defaults to type :string
    field :server_id, :integer
    field :channel_id, :integer
    field :operator
    field :tpl_text
    field :enabled, :boolean, default: true
    timestamps()
  end
end
