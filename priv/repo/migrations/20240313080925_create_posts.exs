defmodule News2Post.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :preamble, :text
      add :sections, :text
      add :status, :string, default: "reviewing", null: false
      add :url, :string, default: nil, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
