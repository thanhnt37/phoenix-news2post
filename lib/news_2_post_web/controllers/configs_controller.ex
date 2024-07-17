defmodule News2PostWeb.ConfigsController do
  use News2PostWeb, :controller

  alias News2Post.Accounts
  alias News2Post.Accounts.User

  def edit(conn, _params) do
    user = conn.assigns[:current_user]
    configs = if user.configs == "", do: "{}", else: user.configs
    configs = JSON.decode!(configs)

    render(conn, :edit, configs: configs)
  end

  def update(conn, params) do
    with {:ok, sanitized_endpoint} <- validate_endpoint(Map.get(params, "endpoint", "")) do
      user = conn.assigns[:current_user]

      configs = %{
        "endpoint": sanitized_endpoint,
        "username": Map.get(params, "username", ""),
        "app_password": Map.get(params, "app_password", "")
      }
      configs = JSON.encode!(configs)
      case Accounts.update_user_configs(user, %{configs: configs}) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "Configs updated successfully.")
          |> redirect(to: ~p"/configs")
        {:error, changeset} ->
          conn
          |> put_flash(:error, "Failed to update configs.")
          |> redirect(to: ~p"/configs")
      end
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: ~p"/configs")
    end
  end

  def validate_endpoint(endpoint) do
    if String.starts_with?(endpoint, "http") do
      sanitized_endpoint = String.trim_trailing(endpoint, "/")
      {:ok, sanitized_endpoint}
    else
      {:error, "Endpoint must start with http."}
    end
  end

end
