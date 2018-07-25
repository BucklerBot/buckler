defmodule BucklerBot.Fallback do
  require Logger

  def handle_fallback(%{fallback: %{
    "ok" => true,
    "result" => %{
      "chat" => %{
        "id" => chat_id
      },
      "message_id" => message_id,
      "text" => _
      }
    },
    request: %{
      "message" => %{
        "new_chat_member" => %{
          "id" => user_id
        },
      },
    }
  }) do
    DB.Connections.update_welcome_message(chat_id, user_id, message_id)
  end

  def handle_fallback(%{fallback: %{
    "ok" => true,
    "result" => %{
      "chat" => %{
        "id" => chat_id
      },
      "message_id" => message_id,
      "text" => _
      }
    },
    request: %{
      "message" => %{
        "from" => %{
          "id" => user_id
        },
      },
    }
  }) do
    DB.Connections.update_welcome_message(chat_id, user_id, message_id)
  end

  def handle_fallback(conn) do
    Logger.debug("Unexpected fallback: #{inspect conn.fallback}")
  end
end
