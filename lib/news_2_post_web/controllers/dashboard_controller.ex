defmodule News2PostWeb.DashboardController do
  use News2PostWeb, :controller

  import Ecto.Query, warn: false
  alias News2Post.Repo
  alias News2Post.CRUD
  alias News2Post.CRUD.News
  alias News2Post.CRUD.Post
  alias ExAws.Dynamo

  def index(conn, _params) do
#   TODO: query and merge news & posts for dashboard, sort by created_date
#   TODO: put a link from dashboard stats to news & posts page

    table_name = "news2post_dev_News_v2"
    news = all_news(table_name)

    table_name = "news2post_dev_Posts_v2"
    posts = all_posts_v2(table_name)

    collection = Enum.concat(posts, news)
    collection = Enum.sort_by(collection, & &1.created_at, &>=/2)

    render(conn, :index, news_collection: collection)
  end

  def all_news(table_name) do
    Dynamo.scan(
      table_name,
      limit: 5,
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: News)
  end

  def all_posts_v2(table_name) do
    Dynamo.scan(
      table_name,
      limit: 5,
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: Post)
  end
end