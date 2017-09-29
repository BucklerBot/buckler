defmodule BucklerBot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Agala.Bot, [telegram_bot_configuration()], id: "buckler"),
      #supervisor(Registry, [:unique, BucklerBot.Registry]),
      #supervisor(BucklerBot.UserSupervisor, []),
      supervisor(BucklerBot.Repo, []),
      supervisor(DB.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: BucklerBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def telegram_bot_configuration do
    %Agala.BotParams{
      name: "buckler",
      provider: Agala.Provider.Telegram,
      handler: BucklerBot.Handler,
      fallback: BucklerBot.Fallback,
      provider_params: %Agala.Provider.Telegram.Conn.ProviderParams{
        token: Application.get_env(:buckler_bot, :telegram)[:token],
        poll_timeout: :infinity
      }
    }
  end
end
