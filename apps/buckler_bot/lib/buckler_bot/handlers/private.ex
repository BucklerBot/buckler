defmodule BucklerBot.Handlers.Private do
  use Agala.Provider.Telegram, :handler
  import Agala.Conn.Multi

  alias BucklerBot.Repo
  import BucklerBot.Gettext
  require Logger

  def init(opts), do: opts
  def call(conn = %Agala.Conn{
    request: %{"message" => %{"chat" => %{"id" => chat_id, "type" => "private"}, "text" => "/ping"}}
  }, _) do
    conn
    |> send_message(chat_id, "pong")
  end
end
