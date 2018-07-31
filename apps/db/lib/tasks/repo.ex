defmodule DB.Tasks.Repo do
  def migrate do
    path = Path.join(:code.priv_dir(:db), "repo/migrations")
    Ecto.Migrator.run(DB.Repo, path, :up, all: true)
  end
end
