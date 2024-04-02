defmodule News2PostWeb.ApiController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News
  alias News2Post.CRUD.Post

  def get_posts(conn, _params) do
    posts = CRUD.all_posts()

    render(conn, :index, posts: posts)
  end

  def create_post(conn, params) do
    changeset = Post.changeset(%Post{}, params)
    if changeset.valid? do
      post_id = UUID.uuid1()
      record = %{
        "id": post_id,
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

      render(conn, :show, post: post)
    else
      IO.inspect(JSON.encode(changeset.errors))

      render(conn, :response, %{code: 406, message: "Not Acceptable!", data: JSON.encode!(changeset.errors)})
    end
  end

  def show_post(conn, %{"id" => id}) do
    post = CRUD.get_post_by_id(id)
    render(conn, :show, post: post)
  end

end
