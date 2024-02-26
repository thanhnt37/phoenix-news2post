defmodule News2Post.Repo.Migrations.AddStatusColumnToNews do
  use Ecto.Migration

  def change do
    alter table(:news) do
      add :status, :string, default: "reviewing", null: false
    end
  end
end
