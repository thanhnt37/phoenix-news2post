defmodule News2PostWeb.DashboardController do
  use News2PostWeb, :controller
  alias News2Post.CRUD

  def index(conn, _params) do
    news = CRUD.get_news(5)
    posts = CRUD.get_posts("all", 5)

    collection = Enum.concat(posts, news)
    collection = Enum.sort_by(collection, & &1.created_at, &>=/2)

    render(conn, :index, news_collection: collection)
  end
end