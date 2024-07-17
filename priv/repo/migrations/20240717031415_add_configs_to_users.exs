defmodule News2Post.Repo.Migrations.AddConfigsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :configs, :string, default: ""
    end
  end
end
