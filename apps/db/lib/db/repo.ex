defmodule DB.Repo do
  use Ecto.Repo, otp_app: :db
  require Ecto.Query
end
