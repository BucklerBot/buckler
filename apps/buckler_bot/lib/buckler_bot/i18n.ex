defmodule BucklerBot.I18n do
  import BucklerBot.Gettext
  require Logger

  def welcome_message(lang, name, captcha, attempts) do
    Logger.debug("Welcome message with locale: #{lang}")
    Elixir.Gettext.with_locale BucklerBot.Gettext, lang, fn ->
      gettext(
        """
        Hello, *%{name}*!

        Please, solve the captcha:

        %{captcha}

        Attempts remaining: *%{attempts}*
        If you don't answer - you'll get banned from the channel...
        Good luck!
        """,
        name: name,
        captcha: captcha,
        attempts: attempts
      )
    end
  end
end
