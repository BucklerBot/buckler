defmodule DB.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [
    :user_id, :name, :connected_message_id, :answer,
    :welcome_message_id, :lang, :attempts,
  ]
  @required_fields [
    :user_id, :name, :connected_message_id, :answer,
    :lang, :attempts,
  ]
  schema "customers" do
    field :name, :string
    field :user_id, :integer
    field :connected_message_id, :integer
    field :welcome_message_id, :integer
    field :answer, :string
    field :lang, :string
    field :attempts, :integer

    belongs_to :chat, DB.Chat, type: :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:chat)
  end
end
