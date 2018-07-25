defmodule BucklerBot.Chain do
  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler

  chain(Agala.Chain.Loopback)
  chain(:handle)

  alias DB.Connections
  alias BucklerBot.I18n
  require Logger

  def handle(
        conn = %Agala.Conn{
          request: %{"message" => %{"chat" => %{"type" => "private"}}}
        },
        _
      ) do
    Logger.debug("New request in private chat!")
    BucklerBot.Handlers.Private.call(conn, [])
  end

  def handle(
        conn = %Agala.Conn{
          request: %{
            "message" => %{"chat" => %{"id" => chat_id}, "left_chat_member" => %{"id" => user_id}, "message_id" => leave_message_id}
          }
        },
        _
      ) do
    case Connections.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        Connections.delete_chatuser(chat_id, user_id)
        delete_message(conn, chat_id, user.connected_message_id)
        delete_message(conn, chat_id, user.welcome_message_id)
        delete_message(conn, chat_id, leave_message_id)

      _ ->
        :do_nothing
    end

    conn |> Agala.Conn.halt()
  end

  def handle(
        conn = %Agala.Conn{
          request: %{
            "message" => %{
              "message_id" => message_id,
              "chat" => %{
                "id" => chat_id
              },
              "new_chat_member" => %{
                "first_name" => first_name,
                "id" => user_id,
                "is_bot" => false
              }
            }
          }
        },
      ) do
    Logger.debug("New user connected: #{first_name}")

    with {:ok, chat} <- Connections.get_or_create_chat(chat_id),
         %{captcha: captcha, answer: answer} <- BucklerBot.Captcha.generate_captcha(chat.lang),
         {:ok, user} <- Connections.connect_user(chat_id, user_id, first_name, answer, message_id) do
      send_message(
        conn,
        chat_id,
        I18n.welcome_message(user.lang, user.name, captcha, user.attempts),
        reply_to_message_id: message_id,
        parse_mode: "Markdown"
      )
      # |> IO.inspect(label: "New message creation response")
      |> handle_welcome_message(user_id)
    end

    conn
  end

  defp handle_welcome_message(
         {:ok,
          %{
            "ok" => true,
            "result" => %{
              "chat" => %{
                "id" => chat_id
              },
              "message_id" => message_id,
              "text" => _
            }
          }}, user_id
       ) do
    DB.Connections.update_welcome_message(chat_id, user_id, message_id)
  end

  #################################################

  def handle(
        conn = %Agala.Conn{
          request: request
        },
        _
      ) do
    Logger.error("Unexpected message:\n#{inspect(request)}")
    conn
  end
end
