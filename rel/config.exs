# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"OOjxZrybU>O}8z<^fsx2jlQ}^RgV|XXXcaJtRsKPkei2*,ot8<D$o4iI><v2*G:y"
end

environment :prod do
  set vm_args: "rel/vm.args"
  set include_erts: true
  set include_src: false
  set cookie: :"s<jYNRfYQEG=[bJ*7b(!|6tZ<fHrEc>2WC{LZ4xjxkAmR%pBgui=]Q%f/Y`5(wdj"
  set output_dir: "rel/buckler_bot"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :buckler do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    buckler_bot: :permanent
  ]
end

