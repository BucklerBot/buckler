use Mix.Config

config :db, DB.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  loggers: []

config :logger, level: :info
