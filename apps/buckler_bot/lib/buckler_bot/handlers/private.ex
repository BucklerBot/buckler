defmodule BucklerBot.Handlers.Private do
  use Agala.Provider.Telegram, :handler

  import BucklerBot.Gettext
  require Logger

  def init(opts), do: opts
  def call(conn = %Agala.Conn{
    request: %{"message" => %{"chat" => %{"id" => chat_id, "type" => "private"}, "text" => "/ping"}}
  }, _) do
    conn
    |> send_message(chat_id, "BucklerBot is now working")
  end

  def call(conn = %Agala.Conn{
    request: %{"message" => %{"chat" => %{"id" => chat_id, "first_name" => first_name, "type" => "private"}, "text" => "/start"}}
  }, _) do
    conn
    |> send_message(
      chat_id,
      gettext(
      """
      Hello, %{first_name}!

      I'm *BucklerBot*, and I'll defend your group or chat from dirsty spammers.

      1. Add me as Administrator to your group.
      2. Give me only two rights: to *Ban users* and to *Delete messages*
      3. *???*
      4. Enjoy!

      If you have any questions or issues - welcome to our project's
      repo - https://github.com/BucklerBot/buckler
      """,
      first_name: first_name),
      parse_mode: "Markdown"
    )
  end
end
