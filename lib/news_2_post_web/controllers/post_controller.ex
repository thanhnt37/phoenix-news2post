defmodule News2PostWeb.PostController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.Post

  def index(conn, _params) do
    status = Map.get(conn.params, "status", "all");
    posts = CRUD.list_posts(status)
    render(conn, :index, posts: posts, status: status)
  end

  def new(conn, _params) do
    changeset = CRUD.change_post(%Post{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case CRUD.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = CRUD.get_post!(id)
    IO.inspect(post.sections)
    IO.puts("post.sections: #{inspect(post.sections, pretty: true)}")

    sections = JSON.decode!(post.sections)
    IO.puts("sections: #{inspect(sections, pretty: true)}")

    render(conn, :show, post: post, sections: sections)
  end

  def edit(conn, %{"id" => id}) do
    post = CRUD.get_post!(id)
    changeset = CRUD.change_post(post)
    sections = JSON.decode!(post.sections)
    IO.puts("sections: #{inspect(sections, pretty: true)}")

    render(conn, :edit, post: post, changeset: changeset, sections: sections)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = CRUD.get_post!(id)

    sections = Map.values(post_params["sections"])
    sections = JSON.encode!(sections)

    updated_data = %{post_params | "sections" => sections}
    IO.puts("updated_data: #{inspect(updated_data, pretty: true)}")
    IO.inspect("is_map updated_data: #{is_map(updated_data)}")

    case CRUD.update_post(post, updated_data) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def approve(conn, params) do
    status = %{
      "status" => "approved"
    }
    IO.puts("status: #{inspect(status, pretty: true)}")

    post = CRUD.get_post!(params["id"])
    case CRUD.update_post(post, status) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post Approved successfully.")
        |> redirect(to: ~p"/posts")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = CRUD.get_post!(id)
    {:ok, _post} = CRUD.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
