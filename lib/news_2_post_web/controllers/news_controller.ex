defmodule News2PostWeb.NewsController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News
  alias ExAws.Dynamo

  def index(conn, _params) do
    table_name = "news2post_dev_News_v2"
    news = all_news(table_name)
#    news = CRUD.list_news()

    IO.inspect(news)
    render(conn, :index, news_collection: news)
  end

  def all_news(table_name) do
    Dynamo.scan(
      table_name,
      limit: 5,
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: News)
  end
end
