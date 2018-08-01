use Mix.Config

config :db, DB.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "buckler_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432",
  loggers: []

config :logger,
  level: :info
