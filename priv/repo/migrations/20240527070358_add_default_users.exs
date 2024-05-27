defmodule News2Post.Repo.Migrations.AddDefaultUsers do
  use Ecto.Migration

  def up do
    hashed_password = Bcrypt.hash_pwd_salt("AdminPassword@123")

    execute """
    INSERT INTO users (email, hashed_password, first_name, last_name, role, inserted_at, updated_at)
    VALUES ('admin@adabeat.com', '#{hashed_password}', 'Admin', 'User', 'admin', NOW(), NOW())
    """
  end

  def down do
    execute """
    DELETE FROM users WHERE email = 'admin@adabeat.com'
    """
  end

end
