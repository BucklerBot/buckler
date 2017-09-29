defmodule DB.Repo.Migrations.CreateChat do
  #lagnuage codes https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
  use Ecto.Migration

  def change do
    create table "chats", primary_key: false do
      add :id, :bigint, primary_key: true
      add :lang, :string, default: "en"
      add :attempts, :integer, default: 3
    end
  end
end
