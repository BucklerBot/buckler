defmodule BucklerBot.RepoTest do
  use ExUnit.Case
  alias Agala.Conn
  alias BucklerBot.{Repo, Model.User}

  setup do
    Repo.start_link
    :dets.delete_all_objects(db_name())

    :ok
  end

  defp db_name, do: Application.get_env(:buckler_bot, Repo)[:db_name] |> String.to_atom

  def insert_user(%User{chat_id: chat_id, user_id: user_id}=user) do
    :dets.insert(db_name(), { {chat_id, user_id}, user })
    user
  end

  describe "#new_user" do
    setup do
      [conn: %Conn{request: %{
        "message" => %{
          "chat" => %{
            "id" => 205798533
          },
          "new_chat_member" => %{
            "first_name" => "Nikolay",
            "id" => 1
          },
          "message_id" => 2
        },
      }}]
    end

    test "should successfully save user", %{conn: conn} do
      Repo.new_user(conn, "1488")
      assert {true, %User{user_id: 1, answer: "1488", name: "Nikolay"}} = Repo.user_unauthorized?(205798533, 1)
    end
  end

  describe "#update_messages_to_delete" do
    setup do
      [user: insert_user(%User{chat_id: 1, user_id: 2})]
    end

    test "should successfully update message for delete", %{user: %User{chat_id: chat_id, user_id: user_id}} do
      {true, %User{message_to_delete: current_message_to_delete}} = Repo.user_unauthorized?(chat_id, user_id)
      assert is_nil(current_message_to_delete)

      Repo.update_messages_to_delete(chat_id, user_id, 3)

      {true, %User{message_to_delete: new_message_to_delete}} = Repo.user_unauthorized?(chat_id, user_id)

      assert new_message_to_delete == 3
    end
  end

  describe "#delete_user" do
    setup do
      [user: insert_user(%User{chat_id: 1, user_id: 2})]
    end

    test "should successfully update message for delete", %{user: %User{chat_id: chat_id, user_id: user_id}} do
      Repo.delete_user(chat_id, user_id)

      assert {false, :authorized} = Repo.user_unauthorized?(chat_id, user_id)
    end
  end
end
