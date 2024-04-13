defmodule News2PostWeb.OAuthController do
  use News2PostWeb, :controller

  alias News2Post.Repo
  alias News2Post.OauthApplications.OauthApplication

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
