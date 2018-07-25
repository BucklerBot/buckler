defmodule BucklerBot.Handler do
  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler
  import Agala.Conn.Multi

  chain Agala.Chain.Loopback
  chain :handle

  alias DB.Connections
  alias BucklerBot.I18n
  require Logger

  def handle(conn = %Agala.Conn{
    request: %{"message" => %{"chat" => %{"type" => "private"}}}
  }, _) do
    Logger.debug("New request in private chat!")
    BucklerBot.Handlers.Private.call(conn, [])
  end

  def handle(conn = %Agala.Conn{
    request: %{"message" => %{"chat" => %{"id" => chat_id}, "left_chat_member" => %{"id" => user_id}}}
  }, _) do
    case Connections.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        multi do
          Connections.delete_chatuser(chat_id, user_id)
          add delete_message(conn, chat_id, user.connected_message_id)
          add delete_message(conn, chat_id, user.welcome_message_id)
        end
      _ -> conn |> Agala.Conn.halt
    end
  end

  def handle(conn = %Agala.Conn{
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
  }, _) do
    Logger.debug "New user connected: #{first_name}"
    with {:ok, chat} <- Connections.get_or_create_chat(chat_id),
        %{captcha: captcha, answer: answer} <- BucklerBot.Captcha.generate_captcha(chat.lang),
        {:ok, user} <- Connections.connect_user(chat_id, user_id, first_name, answer, message_id)
    do
      conn
      |> send_message(
        chat_id,
        I18n.welcome_message(user.lang, user.name, captcha, user.attempts),
        reply_to_message_id: message_id,
        parse_mode: "Markdown"
      )
    end
  end

  def handle(conn = %Agala.Conn{
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
  }, _) do
    case Connections.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        process_captcha_check(user.answer == text, conn, message_id, user)
      _ ->
        conn |> Agala.Conn.halt
    end
  end

  def handle(conn = %Agala.Conn{
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
  }, _) do
    Logger.debug("New media message!")
    case Connections.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        process_captcha_check(false, conn, message_id, user)
      _ -> conn |> Agala.Conn.halt
    end
  end

  def process_captcha_check(true, conn, message_id, user) do
    multi do
      add delete_message(conn, user.chat_id, user.welcome_message_id)
      add delete_message(conn, user.chat_id, message_id)
      Connections.delete_chatuser(user.chat_id, user.user_id)
    end
  end
  def process_captcha_check(
    false,
    conn,
    message_id,
    %{attempts: attempts} = user
  ) when attempts < 2  do
    # ban here
    multi do
      {:ok, user} = Connections.delete_chatuser(user.chat_id, user.user_id)
      add delete_message(conn, user.chat_id, user.welcome_message_id)
      add delete_message(conn, user.chat_id, user.connected_message_id)
      add delete_message(conn, user.chat_id, message_id)
      add kick_chat_member(conn, user.chat_id, user.user_id)
    end
  end
  def process_captcha_check(false, conn, message_id, user) do
    # decrease attempt
    with %{captcha: captcha, answer: answer} <- BucklerBot.Captcha.generate_captcha(user.lang),
          {:ok, user} <- Connections.decrease_attempts(user.chat_id, user.user_id, answer)
    do
      multi do
        add delete_message(conn, user.chat_id, user.welcome_message_id)
        add delete_message(conn, user.chat_id, message_id)
        add send_message(
          conn,
          user.chat_id,
          I18n.welcome_message(user.lang, user.name, captcha, user.attempts),
          reply_to_message_id: user.connected_message_id,
          parse_mode: "Markdown"
        )
      end
    end
  end
end
