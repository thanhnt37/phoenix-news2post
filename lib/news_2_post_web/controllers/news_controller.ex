defmodule News2PostWeb.NewsController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News

  def index(conn, _params) do
    news = CRUD.all_news()

    render(conn, :index, news_collection: news)
  end

end
