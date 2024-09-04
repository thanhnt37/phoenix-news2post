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
    integration_type = Map.get(params, "integration_type", "")
    if integration_type == "wordpress" do
      update_wordpress_configs(conn, params)
    else
      if integration_type == "webflow" do
        update_webflow_configs(conn, params)
      end
    end

    conn
    |> put_flash(:error, "Bad request parameters.")
    |> redirect(to: ~p"/configs")
  end

  defp update_webflow_configs(conn, params) do
    user = conn.assigns[:current_user]

    webflow_configs = %{
      "integration_type": "webflow",
      "wordpress": %{
        "endpoint": "",
        "username": "",
        "app_password": ""
      },
      "webflow": %{
        "token": Map.get(params, "token", ""),
        "site_id": Map.get(params, "site_id", ""),
        "collection_id": ""
      }
    }
    configs = JSON.encode!(webflow_configs)
    case Accounts.update_user_configs(user, %{configs: configs}) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Webflow configs updated successfully.")
        |> redirect(to: ~p"/configs")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failed to update Webflow configs.")
        |> redirect(to: ~p"/configs")
    end
  end

  defp update_wordpress_configs(conn, params) do
    with {:ok, sanitized_endpoint} <- validate_endpoint(Map.get(params, "endpoint", "")) do
      user = conn.assigns[:current_user]

      wordpress_configs = %{
        "integration_type": "wordpress",
        "wordpress": %{
          "endpoint": sanitized_endpoint,
          "username": Map.get(params, "username", ""),
          "app_password": Map.get(params, "app_password", "")
        },
        "webflow": %{
          "token": "",
          "site_id": "",
          "collection_id": ""
        }
      }
      configs = JSON.encode!(wordpress_configs)
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
