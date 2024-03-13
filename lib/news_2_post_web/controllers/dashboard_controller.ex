defmodule News2PostWeb.DashboardController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News

  def index(conn, _params) do
    news = CRUD.all_news()
    current_date = Date.utc_today()
    IO.inspect(current_date)
    render(conn, :index, current_date: current_date, news_collection: news)
  end
end