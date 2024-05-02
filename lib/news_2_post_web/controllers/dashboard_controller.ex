defmodule News2PostWeb.DashboardController do
  use News2PostWeb, :controller
  alias News2Post.CRUD

  def index(conn, _params) do
    news = CRUD.get_news_v2(5, "next", %{})
    posts = CRUD.get_posts_v2("all", 5, "next", %{})

    collection = Enum.concat(posts.items, news.items)
    collection = Enum.sort_by(collection, & &1.sk, &>=/2)

    render(conn, :index, news_collection: collection)
  end
end