defmodule BucklerBot.Handler do
  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler
  import Agala.Conn.Multi

  chain Agala.Chain.Loopback
  chain :handle

  alias BucklerBot.Repo
  import BucklerBot.Gettext
  require Logger

  def handle(conn = %Agala.Conn{
    request: %{"message" => %{"chat" => %{"id" => chat_id}, "left_chat_member" => %{"id" => user_id}}}
  }, _) do
    case Repo.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        Repo.delete_user(chat_id, user_id)
        conn
        |> delete_message(chat_id, user.message_to_delete)
      _ -> conn |> Agala.Conn.halt
    end
  end

  def handle(conn = %Agala.Conn{
    request_bot_params: %Agala.BotParams{name: name},
    request: %{
      "message" => %{
        "message_id" => message_id,
        "chat" => %{
          "id" => chat_id
        },
        "new_chat_member" => %{
          "first_name" => first_name,
          "id" => user_id
        }
      }
    }
  }, _) do
    with %{captcha: captcha, answer: answer} <- BucklerBot.Captcha.generate_captcha(),
         _ <- Repo.new_user(conn, answer)
    do
      conn
      |> send_message(
        chat_id,
        gettext("""
        Hello, *%{first_name}*!

        Please, tell us:
        *%{captcha}*

        If you will not answer - you will be banned from the channel...
        Good luck!
        """,
        first_name: first_name, captcha: captcha),
        reply_to_message_id: message_id,
        parse_mode: "Markdown"
      )
    end
  end

  def handle(conn = %Agala.Conn{
    request_bot_params: %Agala.BotParams{name: name},
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
    case Repo.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        Repo.delete_user(chat_id, user_id)
        multi do
          case text == user.answer do
            true ->
              add delete_message(conn, chat_id, user.message_to_delete)
              add delete_message(conn, chat_id, message_id)
            false ->
              add delete_message(conn, chat_id, user.message_to_delete)
              add delete_message(conn, chat_id, message_id)
              add kick_chat_member(conn, chat_id, user_id)
          end
        end
      {false, _} -> conn |> Agala.Conn.halt
    end
  end

  def handle(conn = %Agala.Conn{
    request_bot_params: %Agala.BotParams{name: name},
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
    case Repo.user_unauthorized?(chat_id, user_id) do
      {true, user} ->
        Logger.warn("User unauthorized")
        Repo.delete_user(chat_id, user_id)
        multi do
          add delete_message(conn, chat_id, message_id)
          add delete_message(conn, chat_id, user.message_to_delete)
          add kick_chat_member(conn, chat_id, user_id)
        end
      _ -> conn |> Agala.Conn.halt
    end
  end
end
