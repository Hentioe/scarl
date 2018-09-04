defmodule Storage.Repo do
  use Ecto.Repo,
    otp_app: :storage,
    adapter: Sqlite.Ecto2
end
