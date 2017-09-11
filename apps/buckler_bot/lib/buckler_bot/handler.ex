defmodule BucklerBot.Handler do
  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler

  chain Agala.Chain.Loopback
  chain :handle

  def handle(conn = %Agala.Conn{
    request_bot_params: %Agala.BotParams{name: name},
    request: %{"message" => %{"text" => "delete", "message_id" => message_id, "chat" => %{"id" => id}}}
  }, _) do
    conn
    |> delete_message(id, message_id)
  end

  def handle(conn = %Agala.Conn{
    request_bot_params: %Agala.BotParams{name: name},
    request: %{"message" => %{"text" => text, "chat" => %{"id" => id}}}
  }, _) do
    conn
    |> send_message(id, text)
  end

  def handle(conn = %Agala.Conn{
    request_bot_params: %Agala.BotParams{name: name},
    request: %{"message" => %{"chat" => %{"id" => id}, "left_chat_member" => %{"first_name" => first_name}}}
  }, _) do
    conn
    |> send_message(id, "#{first_name} вышел нахер")
  end
end
