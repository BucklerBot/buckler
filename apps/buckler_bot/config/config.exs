use Mix.Config

config :buckler_bot, :telegram,
  token: System.get_env("TELEGRAM_TOKEN")

config :buckler_bot,
  loyalty_count: 3

import_config "#{Mix.env}.exs"
