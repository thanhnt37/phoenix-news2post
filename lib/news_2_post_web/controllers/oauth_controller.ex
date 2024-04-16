defmodule News2PostWeb.OAuthController do
  use News2PostWeb, :controller

  alias News2Post.Repo
  alias News2Post.OauthApplications.OauthApplication
  alias ExOauth2Provider.Applications

  def create_application(conn, params) do
    oauth_signature = Application.get_env(:news_2_post, ExOauth2Provider)[:signature]
    IO.puts("..... params: #{inspect(params, pretty: true)}")
    signature = Map.get(params, "signature", "")
    if signature != oauth_signature do
      send_resp(conn, 403, "403 Forbidden !!!")
    else
      new_app = %{
        name: Map.get(params, "name", ""),
        redirect_uri: Map.get(params, "redirect_uri", "https://example.com/callback"),
      }
      IO.puts("..... new_app: #{inspect(new_app, pretty: true)}")
      case Applications.create_application(nil, new_app, otp_app: :news_2_post) do
        {:ok, application} ->
          IO.puts("..... application: #{inspect(application, pretty: true)}")
          json(conn, %{application: %{
            id: application.id,
            name: application.name,
            uid: application.uid,
            secret: application.secret
          }})
        {:error, changeset} ->
          send_resp(conn, 401, JSON.encode!(changeset.errors))
      end
    end
  end

  def grant_token(conn, params) do
    request = %{
      "grant_type" => "client_credentials",
      "client_id" => Map.get(params, "client_id", ""),
      "client_secret" => Map.get(params, "client_secret", "")
    }
    case ExOauth2Provider.Token.grant(request, otp_app: :news_2_post) do
      {:ok, access_token} ->
        json(conn, %{access_token: access_token})
      {:error, error, http_status} ->
        send_resp(conn, 401, "Unauthorized")
    end
  end
end
