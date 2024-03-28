defmodule News2PostWeb.PostController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.Post
  alias ExAws.Dynamo

  def index(conn, _params) do
    status = Map.get(conn.params, "status", "all");

    posts = CRUD.all_posts(status)

    render(conn, :index, posts: posts, status: status)
  end

  def show(conn, %{"id" => id}) do
    post = CRUD.get_post_by_id(id)
    sections = JSON.decode!(post.sections)

    render(conn, :show, post: post, sections: sections)
  end

  def edit(conn, %{"id" => id}) do
    post = CRUD.get_post_by_id(id)
    sections = JSON.decode!(post.sections)

    render(conn, :edit, post: post, sections: sections)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = CRUD.get_post_by_id(id)

    sections = Map.values(post_params["sections"])
    sections = JSON.encode!(sections)

    updated_data = %{post_params | "sections" => sections}
    CRUD.update_post(
      post.id, post.created_at,
      %{:title => updated_data["title"], :description => updated_data["description"], :sections => updated_data["sections"]}
    )

    conn
    |> put_flash(:info, "Post updated successfully.")
    |> redirect(to: ~p"/posts/#{post}")
  end

  def approve(conn, params) do
    post = CRUD.get_post_by_id(params["id"])
    CRUD.update_post(post.id, post.created_at, %{:status => "approved"})

    conn
    |> put_flash(:info, "Post Approved successfully.")
    |> redirect(to: ~p"/posts")
  end

  def delete(conn, %{"id" => id}) do
    post = CRUD.get_post_by_id(id)
    CRUD.delete_post(post.id, post.created_at)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

end
