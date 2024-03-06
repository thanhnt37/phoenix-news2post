defmodule News2Post.Repo.Migrations.AddColumnUrlToNews do
  use Ecto.Migration

  def change do
    alter table(:news) do
      add :url, :string, default: nil, null: true
    end
  end
end
