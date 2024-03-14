defmodule News2Post.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :title, :string
      add :description, :text
      add :url, :string
      add :published_at, :date, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
