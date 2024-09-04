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
    webflow_token = Map.get(params, "token", "")
    webflow_site_id = Map.get(params, "site_id", "")
    case get_webflow_collections(webflow_token, webflow_site_id) do
      {:ok, body} ->
        # TODO: validation
        body = JSON.decode!(body)
        collections = body["collections"]
        collection_id = Map.get(params, "collection_id", List.first(collections)["id"])

        webflow_configs = %{
          "integration_type": "webflow",
          "wordpress": %{
            "endpoint": "",
            "username": "",
            "app_password": ""
          },
          "webflow": %{
            "token": webflow_token,
            "site_id": webflow_site_id,
            "collections": collections,
            "collection_id": collection_id
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
      {:error, reason} ->
        IO.inspect(reason, label: "...... error: ")
        conn
        |> put_flash(:error, "Invalid Webflow parameters!")
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
          "collections": [],
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

  defp get_webflow_collections(token, site_id) do
    url = "https://api.webflow.com/v2/sites/#{site_id}/collections"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]
    case :hackney.request(:get, url, headers, "", [recv_timeout: 5000]) do
      {:ok, status_code, _headers, client_ref} when status_code in 200..299 ->
        {:ok, body} = :hackney.body(client_ref)
        {:ok, body}

      {:ok, status_code, _headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        {:error, "Request failed with status code: #{status_code}."}

      {:error, reason} ->
        {:error, "Request failed with reason: #{reason}"}
    end
  end

end
