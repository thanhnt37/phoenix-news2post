defmodule News2Post.Repo.Migrations.AddFirstLastNameAndRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :role, :string, default: "user" # admin || user
    end
  end

end
