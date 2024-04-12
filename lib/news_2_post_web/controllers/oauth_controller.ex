defmodule News2PostWeb.OAuthController do
  use News2PostWeb, :controller

  alias News2Post.Repo
  alias News2Post.OauthApplications.OauthApplication

#  def create(conn, %{"client_id" => client_id, "" => client_secret, "grant_type" => grant_type} = params) do
  def create(conn, params) do

    IO.puts("..... params: #{inspect(params, pretty: true)}")

#    id = generate_client_id()
#    secret = generate_client_secret()
#    new_app = %{
#      name: "thanhnt testing",
#      uid: id,
#      secret: secret,
#      redirect_uri: "http://example.com/callback"
#    }
#    IO.puts("..... new_app: #{inspect(new_app, pretty: true)}")
#    %OauthApplication{}
#    |> OauthApplication.changeset(new_app)
#    |> Repo.insert()

    case ExOauth2Provider.Token.grant(params, otp_app: :news_2_post) do
      {:ok, access_token} ->
        IO.puts("..... access_token: #{inspect(access_token, pretty: true)}")
        json(conn, %{access_token: access_token})
      {:error, error, http_status} ->
        IO.puts("..... error: #{inspect(error, pretty: true)}")
        IO.puts("..... http_status: #{inspect(http_status, pretty: true)}")
        send_resp(conn, 401, "Unauthorized")
    end
  end

  def generate_client_id do
    :crypto.strong_rand_bytes(20) |> Base.url_encode64() |> binary_part(0, 20)
  end

  def generate_client_secret do
    :crypto.strong_rand_bytes(40) |> Base.url_encode64()
  end

end
