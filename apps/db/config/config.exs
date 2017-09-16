use Mix.Config

config :db,
  ecto_repos: [DB.Repo]

import_config "#{Mix.env}.exs"
