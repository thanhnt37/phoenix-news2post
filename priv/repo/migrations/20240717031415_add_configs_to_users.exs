defmodule News2Post.Repo.Migrations.AddConfigsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :configs, :text, default: ""
    end
  end
end
