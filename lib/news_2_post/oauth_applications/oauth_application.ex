defmodule News2Post.OauthApplications.OauthApplication do

  use Ecto.Schema
  import Ecto.Changeset
  use ExOauth2Provider.Applications.Application, otp_app: :news_2_post

  schema "oauth_applications" do
    application_fields()

    timestamps()
  end

  def changeset(application, attrs) do
    application
    |> cast(attrs, [:name, :uid, :secret, :redirect_uri])
    |> validate_required([:name, :uid, :secret, :redirect_uri])
  end
end
