defmodule News2PostWeb.ApiController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News
  alias News2Post.CRUD.Post

  def get_posts(conn, _params) do
    page_size = 10
    status = Map.get(conn.params, "status", "all")
    last_evaluated_key = Map.get(conn.params, "k", "{}")
    last_evaluated_key = JSON.decode!(last_evaluated_key)
    page_type = Map.get(conn.params, "t", "next")

    posts = CRUD.get_posts_v2(status, page_size, page_type, last_evaluated_key)

    render(conn, :get_posts, posts: posts.items)
  end

  def create_post(conn, params) do
    changeset = Post.changeset(%Post{}, params)
    if changeset.valid? do
      post_id = UUID.uuid1()
      record = %{
        "pk": "posts",
        "sk": post_id,
        "title": params["title"],
        "description": params["description"],
        "sections": params["sections"],
        "url": params["url"],
        "status": "reviewing",
        "created_at": DateTime.to_string(DateTime.utc_now()),
      }
      IO.puts("..... record: #{inspect(record, pretty: true)}")

      # TODO: validate sections format
      CRUD.create_post(record)
      post = CRUD.get_post_by_id(post_id)
      IO.puts("..... post: #{inspect(post, pretty: true)}")

      render(conn, :show_post, post: post)
    else
      IO.inspect(JSON.encode(changeset.errors))

      render(conn, :response, %{code: 406, message: "Not Acceptable!", data: JSON.encode!(changeset.errors)})
    end
  end

  def show_post(conn, %{"sk" => sk}) do
    post = CRUD.get_post_by_id(sk)
    render(conn, :show_post, post: post)
  end

  def get_news(conn, _params) do
    page_size = 10
    last_evaluated_key = Map.get(conn.params, "k", "{}")
    last_evaluated_key = JSON.decode!(last_evaluated_key)
    page_type = Map.get(conn.params, "t", "next")

    news = CRUD.get_news_v2(page_size, page_type, last_evaluated_key)

    render(conn, :get_news, news: news.items)
  end

  def create_news(conn, params) do
    changeset = News.changeset(%News{}, params)
    if changeset.valid? do
      news_id = UUID.uuid1()
      record = %{
        "pk": "news",
        "sk": news_id,
        "title": params["title"],
        "description": params["description"],
        "url": params["url"],
        "status": "raw",
        "published_at": params["published_at"],
        "created_at": DateTime.to_string(DateTime.utc_now()),
      }
      IO.puts("..... record: #{inspect(record, pretty: true)}")

      CRUD.create_news(record)
      news = CRUD.get_news_by_id(news_id)
      IO.puts("..... news: #{inspect(news, pretty: true)}")

      render(conn, :show_news, news: news)
    else
      IO.inspect(JSON.encode(changeset.errors))

      render(conn, :response, %{code: 406, message: "Not Acceptable!", data: JSON.encode!(changeset.errors)})
    end
  end

  def show_news(conn, %{"sk" => sk}) do
    news = CRUD.get_news_by_id(sk)
    render(conn, :show_news, news: news)
  end

end
