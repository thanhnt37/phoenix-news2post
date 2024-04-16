defmodule News2Post.OauthApplications.OauthApplication do
  use Ecto.Schema
  use ExOauth2Provider.Applications.Application, otp_app: :news_2_post

  schema "oauth_applications" do
    application_fields()

    timestamps()
  end
end
