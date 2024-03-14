defmodule News2PostWeb.DashboardController do
  use News2PostWeb, :controller

  import Ecto.Query, warn: false
  alias News2Post.Repo
  alias News2Post.CRUD
  alias News2Post.CRUD.News
  alias News2Post.CRUD.Post

  def index(conn, _params) do
#   TODO: query and merge news & posts for dashboard, sort by created_date
#   TODO: put a link from dashboard stats to news & posts page

    posts = Post
            |> order_by([i], desc: i.id)
            |> limit(5)
            |> Repo.all()

    posts = Enum.map(posts, fn(item) ->
      Map.update!(item, :id, fn(id) -> "p#{id}" end)
    end)

    news = News
            |> order_by([i], desc: i.id)
            |> limit(5)
            |> Repo.all()
    news = Enum.map(news, fn(item) ->
      Map.update!(item, :id, fn(id) -> "n#{id}" end)
      |> Map.put(:status, "raw")
    end)

    collection = Enum.concat(posts, news)
    collection = Enum.sort_by(collection, & &1.inserted_at, &>=/2)

    render(conn, :index, news_collection: collection)
  end
end