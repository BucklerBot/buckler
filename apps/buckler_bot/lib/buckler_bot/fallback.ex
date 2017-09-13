defmodule BucklerBot.Fallback do
  require Logger

  def handle_fallback(conn = %{fallback: %{
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
    BucklerBot.Repo.update_messages_to_delete(chat_id, user_id, message_id)
  end

  def handle_fallback(conn) do
    Logger.warn("Unexpected fallback: #{inspect conn.fallback}")
  end
end
