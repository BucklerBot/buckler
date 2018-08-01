use Mix.Config

config :db, DB.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "buckler",
  username: System.get_env("BUCKLER_SQL_USER"),
  password: System.get_env("BUCKLER_PASS"),
  hostname: System.get_env("BUCKLER_HOST"),
  port: "5432",
  loggers: []

config :logger, level: :info
