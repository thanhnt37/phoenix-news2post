defmodule News2Post.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :title, :string
      add :preamble, :text
      add :sections, :text

      timestamps(type: :utc_datetime)
    end
  end
end
