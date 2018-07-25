defmodule BucklerBot.Bot do
  use Agala.Bot.Poller, [
    otp_app: :buckler_bot,
    provider: Agala.Provider.Telegram,
    chain: BucklerBot.Chain,
    provider_params: %Agala.Provider.Telegram.Conn.ProviderParams{
      poll_timeout: :infinity,
      # token: Application.get_env(:buckler_bot, :telegram)[:token]
      token: "448886421:AAHCwfLw4sr5js-4hp6qlGDqCjAJq4bSZJw"
    }
  ]
end
