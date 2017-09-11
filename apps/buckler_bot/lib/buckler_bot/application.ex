defmodule BucklerBot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Agala.Bot, [telegram_bot_configuration()], id: "buckler")
    ]

    opts = [strategy: :one_for_one, name: BucklerBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def telegram_bot_configuration do
    %Agala.BotParams{
      name: "buckler",
      provider: Agala.Provider.Telegram,
      handler: BucklerBot.Handler,
      provider_params: %Agala.Provider.Telegram.Conn.ProviderParams{
        token: System.get_env("TELEGRAM_TOKEN"),
        poll_timeout: :infinity
      }
    }
  end
end
