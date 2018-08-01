defmodule BucklerBot.Chain do
  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler

  chain(Agala.Chain.Loopback)
  chain(:handle)

  alias DB.Connections
  alias BucklerBot.I18n
  require Logger

  # Forward private messages into specific chain
  def handle(
        conn = %Agala.Conn{
          request: %{"message" => %{"chat" => %{"type" => "private"}}}
        },
        _
      ) do
    Logger.debug("New request in private chat!")
    BucklerBot.Handlers.Private.call(conn, [])
  end

  # done
  def handle(
        conn = %Agala.Conn{
          request: %{
            "message" => %{
              "chat" => %{"id" => chat_id},
              "left_chat_member" => %{"id" => user_id},
              "message_id" => leave_message_id
            }
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

  # done
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
        _
      ) do
    Logger.debug("New user connected: #{first_name}")

    ### Firstly we check if this user is not valid by our validator
    case BucklerBot.NameValidator.validate(%{first_name: first_name}) do
      {:ok, _} ->
        with {:ok, chat} <- Connections.get_or_create_chat(chat_id),
             %{captcha: captcha, answer: answer} <-
               BucklerBot.Captcha.generate_captcha(chat.lang),
             {:ok, user} <-
               Connections.connect_user(chat_id, user_id, first_name, answer, message_id) do
          send_message(
            conn,
            chat_id,
            I18n.welcome_message(user.lang, user.name, captcha, user.attempts),
            reply_to_message_id: message_id,
            parse_mode: "Markdown"
          )
          |> handle_welcome_message(user_id)
        end

      {:error, _} ->
        kick_chat_member(conn, chat_id, user_id)
        delete_message(conn, chat_id, message_id)
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
          }},
         user_id
       ) do
    DB.Connections.update_welcome_message(chat_id, user_id, message_id)
  end

  ### Dealing with incoming messages
  def handle(
        conn = %Agala.Conn{
          request: %{
            "message" => %{
              "text" => text,
              "message_id" => message_id,
              "chat" => %{
                "id" => chat_id
              },
              "from" => %{
                "id" => user_id
              }
            }
          }
        },
        _
      ) do
    case Connections.user_unauthorized?(chat_id, user_id) do
      {true, user} -> process_captcha_check(user.answer == text, conn, message_id, user)
      _ -> :user_authorized_do_nothing
    end

    conn |> Agala.Conn.halt()
  end

  ### The same with media message
  def handle(
        conn = %Agala.Conn{
          request: %{
            "message" => %{
              "message_id" => message_id,
              "chat" => %{
                "id" => chat_id
              },
              "from" => %{
                "id" => user_id
              }
            }
          }
        },
        _
      ) do
    Logger.debug("New media message!")

    case Connections.user_unauthorized?(chat_id, user_id) do
      {true, user} -> process_captcha_check(false, conn, message_id, user)
      _ -> :user_authorized_do_nothing
    end

    conn |> Agala.Conn.halt()
  end

  # OK case
  defp process_captcha_check(true, conn, message_id, user) do
    delete_message(conn, user.chat_id, user.welcome_message_id)
    delete_message(conn, user.chat_id, message_id)
    Connections.delete_chatuser(user.chat_id, user.user_id)
  end

  # Fail case
  defp process_captcha_check(
         false,
         conn,
         message_id,
         %{attempts: attempts} = user
       )
       when attempts < 2 do
    # ban here
    {:ok, user} = Connections.delete_chatuser(user.chat_id, user.user_id)
    delete_message(conn, user.chat_id, user.welcome_message_id)
    delete_message(conn, user.chat_id, user.connected_message_id)
    delete_message(conn, user.chat_id, message_id)
    kick_chat_member(conn, user.chat_id, user.user_id)
  end

  defp process_captcha_check(false, conn, message_id, user) do
    # decrease attempt
    with %{captcha: captcha, answer: answer} <- BucklerBot.Captcha.generate_captcha(user.lang),
         {:ok, user} <- Connections.decrease_attempts(user.chat_id, user.user_id, answer) do
      delete_message(conn, user.chat_id, user.welcome_message_id)
      delete_message(conn, user.chat_id, message_id)

      send_message(
        conn,
        user.chat_id,
        I18n.welcome_message(user.lang, user.name, captcha, user.attempts),
        reply_to_message_id: user.connected_message_id,
        parse_mode: "Markdown"
      )
      |> handle_welcome_message(user.user_id)
    end
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
