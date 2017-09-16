defmodule DB.User do
  use Ecto.Schema

  schema "users" do
    field :conn, :string
    field :name, :string
    field :message_id, :string
    field :user_id, :string
    field :chat_id, :string
    field :answer, :string
    field :message_to_delete, :string
  end
end
