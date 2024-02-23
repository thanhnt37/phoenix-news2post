defmodule News2Post.Repo do
  use Ecto.Repo,
    otp_app: :news_2_post,
    adapter: Ecto.Adapters.Postgres
end
