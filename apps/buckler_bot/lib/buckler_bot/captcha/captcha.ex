defmodule BucklerBot.Captcha do
  alias BucklerBot.Captcha

  defstruct [
    captcha: nil,
    answer: nil
  ]

  def generate_captcha do
    %Captcha{captcha: "13+25", answer: "38"}
  end
end
