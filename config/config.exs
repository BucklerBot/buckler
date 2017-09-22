use Mix.Config

import_config "../apps/*/config/config.exs"
import_config "#{Mix.env}.exs"
