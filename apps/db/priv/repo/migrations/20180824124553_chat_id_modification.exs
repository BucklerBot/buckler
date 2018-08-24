defmodule DB.Repo.Migrations.ChatIdModification do
  use Ecto.Migration

  def change do
    drop table("customers")
    drop table("chats")

    create table "chats", primary_key: false do
      add :id, :string, primary_key: true
      add :lang, :string, default: "en"
      add :attempts, :integer, default: 3
    end

    create table "customers" do
      add :name, :string, comment: "User's name"
      add :user_id, :bigint, comment: "User's Telegram ID"
      add :answer, :string, comment: "User's captcha answer"
      add :chat_id, references("chats", type: :string, on_delete: :delete_all, on_update: :update_all), comment: "Chat's Telegram ID for entered user"
      add :connected_message_id, :integer, comment: "'%user% connected to channel' message's ID"
      add :welcome_message_id, :integer, comment: "Bot's reply for user's connection"

      add :lang, :string, comment: "Language for bot to speak with user"
      add :attempts, :integer, comment: "Number of current retries for user - with 0 here he's banned"
    end
    create index("customers", [:chat_id, :user_id], unique: true)
  end
end
