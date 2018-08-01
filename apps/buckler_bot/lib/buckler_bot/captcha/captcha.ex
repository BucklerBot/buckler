defmodule BucklerBot.Captcha do
  alias BucklerBot.Captcha
  import BucklerBot.Gettext

  defstruct [
    captcha: nil,
    answer: nil
  ]

  def generate_captcha(lang) do
    lh = :rand.uniform(100)
    rh = :rand.uniform(100)

    Elixir.Gettext.with_locale BucklerBot.Gettext, lang, fn ->
      %Captcha{
        captcha: gettext("*Calculate*: *%{lh}+%{rh}=...*", lh: lh, rh: rh),
        answer: "#{lh+rh}"
      }
    end
  end
end
