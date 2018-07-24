defmodule BucklerBot.Repo do
  use GenServer

  alias BucklerBot.Model.User

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :dets.open_file(db_name(), [type: :set])
  end

  def new_user(conn = %Agala.Conn{
    request: %{
      "message" => %{
        "chat" => %{
          "id" => chat_id
        },
        "new_chat_member" => %{
          "first_name" => name,
          "id" => user_id
        }
      },
    }
  }, answer) do
    :dets.insert(
      db_name(),
      {
        {chat_id, user_id},
        %User{
          conn: conn |> Map.drop([:request]),
          name: name,
          user_id: user_id,
          chat_id: chat_id,
          answer: answer
        }
      })
  end

  def update_messages_to_delete(chat_id, user_id, message_id) do
    [{_, user}] = :dets.lookup(db_name(), {chat_id, user_id})
    :dets.insert(db_name(), {{chat_id, user_id}, user |> Map.put(:message_to_delete, message_id)})
  end

  def delete_user(chat_id, user_id) do
    :dets.delete(db_name(), {chat_id, user_id})
  end

  def user_unauthorized?(chat_id, user_id) do
    case :dets.lookup(db_name(), {chat_id, user_id}) do
      [{_, user}] -> {true, user}
      _ -> {false, :authorized}
    end
  end

  defp db_name do
    Application.get_env(:buckler_bot, __MODULE__)[:db_name] |> String.to_atom
  end
end
