defmodule News2Post.OauthAccessGrants.OauthAccessGrant do
  use Ecto.Schema
  use ExOauth2Provider.AccessGrants.AccessGrant, otp_app: :news_2_post

  schema "oauth_access_grants" do
    access_grant_fields()

    timestamps()
  end
end
