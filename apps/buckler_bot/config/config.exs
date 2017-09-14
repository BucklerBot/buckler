use Mix.Config

config :buckler_bot, :telegram,
  token: System.get_env("TELEGRAM_TOKEN")

config :buckler_bot, BucklerBot.Repo,
  db_name: System.get_env("DB_NAME")
