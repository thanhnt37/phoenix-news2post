defmodule News2PostWeb.UserController do
  use News2PostWeb, :controller

  alias News2Post.Accounts
  alias News2Post.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset, is_new: true)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
      IO.puts("..... loi roi: #{inspect(changeset)}}")

        render(conn, :new, changeset: changeset, is_new: true)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user_registration(user)
    render(conn, :edit, user: user, changeset: changeset, is_new: false)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user_basic_info(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset, is_new: false)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    if user.role == "admin" do
      conn
      |> put_flash(:error, "Cannot delete an admin user.")
      |> redirect(to: ~p"/users/#{user}")
    else
      {:ok, _user} = Accounts.delete_user(user)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: ~p"/users")
    end
  end
end
