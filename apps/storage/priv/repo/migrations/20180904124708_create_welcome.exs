defmodule Storage.Repo.Migrations.CreateWelcome do
  use Ecto.Migration

  def change do
    create table :welcome do
      add :server_id, :integer
      add :channel_id, :integer
      add :operator, :string
      add :tpl_text, :string
      add :enabled, :boolean

      timestamps()
    end
  end
end
