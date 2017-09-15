defmodule BucklerBot.Captcha do
  alias BucklerBot.Captcha

  defstruct [
    captcha: nil,
    answer: nil
  ]

  def generate_captcha do
    lh = :rand.uniform(100)
    rh = :rand.uniform(100)
    %Captcha{captcha: "#{lh}+#{rh}=...", answer: "#{lh+rh}"}
  end
end
