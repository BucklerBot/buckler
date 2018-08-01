defmodule DB.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:id, :lang, :attempts]
  @required_fields [:id]
  schema "chats" do
    field :lang, :string, default: "en"
    field :attempts, :integer, default: 3

    has_many :customers, DB.Customer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:id, name: :chats_pkey)
  end
end
