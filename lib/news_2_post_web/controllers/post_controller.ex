defmodule News2PostWeb.PostController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.Post
  alias ExAws.Dynamo


  def index(conn, _params) do
    table_name = "news2post_dev_Posts_v2"
    status = Map.get(conn.params, "status", "all");
#    posts = CRUD.list_posts(status)

    posts = all_posts_v2(table_name)
#    IO.inspect(posts)

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

    table_name = "news2post_dev_Posts_v2"
#    result = Dynamo.get_item(table_name, %{id: "40b3c688-eb40-11ee-ac52-6e7281ad5aa1", created_at: "2024-03-26 07:12:49.102209Z"})
#             |> ExAws.request!
#             |> Dynamo.decode_item(as: Post)
#    IO.puts("result: #{inspect(result, pretty: true)}")


    post = get_post_by_id(id)
#    IO.puts("post: #{inspect(post, pretty: true)}")

#    post = CRUD.get_post!(id)
#    IO.inspect(post.sections)
#    IO.puts("post.sections: #{inspect(post.sections, pretty: true)}")

    sections = JSON.decode!(post.sections)
#    IO.puts("sections: #{inspect(sections, pretty: true)}")

    render(conn, :show, post: post, sections: sections)
  end

  def edit(conn, %{"id" => id}) do
#    post = CRUD.get_post!(id)
    post = get_post_by_id(id)
    changeset = CRUD.change_post(post)
    sections = JSON.decode!(post.sections)
#    IO.puts("sections: #{inspect(sections, pretty: true)}")

    render(conn, :edit, post: post, changeset: changeset, sections: sections)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = get_post_by_id(id)

    sections = Map.values(post_params["sections"])
    sections = JSON.encode!(sections)

    updated_data = %{post_params | "sections" => sections}
    table_name = "news2post_dev_Posts_v2"
    result = Dynamo.update_item(
               table_name,
               %{id: post.id, created_at: post.created_at},
               %{
                 update_expression: "SET #title = :title, #description = :description, #sections = :sections",
                 expression_attribute_names: %{"#title" => "title", "#description" => "description", "#sections" => "sections"},
                 expression_attribute_values: %{:title => updated_data["title"], :description => updated_data["description"], :sections => updated_data["sections"]},
                 return_values: :updated_new
               }
             )
             |> ExAws.request!
    IO.puts("update_item result: #{inspect(result, pretty: true)}")

    conn
    |> put_flash(:info, "Post updated successfully.")
    |> redirect(to: ~p"/posts/#{post}")
  end

  def approve(conn, params) do
#    status = %{
#      "status" => "approved"
#    }
#    IO.puts("status: #{inspect(status, pretty: true)}")

#    post = CRUD.get_post!(params["id"])
    post = get_post_by_id(params["id"])
#    IO.puts("..... post: #{inspect(post, pretty: true)}")
    table_name = "news2post_dev_Posts_v2"
    Dynamo.update_item(
      table_name,
      %{id: post.id, created_at: post.created_at},
      %{
        update_expression: "SET #status = :status",
        expression_attribute_names: %{"#status" => "status"},
        expression_attribute_values: %{:status => "approved"},
        return_values: :updated_new
      }
    )
    |> ExAws.request!

    conn
    |> put_flash(:info, "Post Approved successfully.")
    |> redirect(to: ~p"/posts")

#    |> ExAws.request!
#    case CRUD.update_post(post, status) do
#      {:ok, _post} ->
#        conn
#        |> put_flash(:info, "Post Approved successfully.")
#        |> redirect(to: ~p"/posts")
#
#      {:error, %Ecto.Changeset{} = changeset} ->
#        render(conn, :edit, post: post, changeset: changeset)
#    end
  end

  def delete(conn, %{"id" => id}) do
#    post = CRUD.get_post!(id)
    post = get_post_by_id(id)
    table_name = "news2post_dev_Posts_v2"
    Dynamo.delete_item(
      table_name,
      %{id: post.id, created_at: post.created_at}
    )
    |> ExAws.request!

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  def all_posts_v2(table_name) do
    Dynamo.scan(
      table_name,
      limit: 5,
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: Post)
  end

  def get_post_by_id(id) do
    table_name = "news2post_dev_Posts_v2"
    result = Dynamo.query(
      table_name,
      #      limit: 10,
      expression_attribute_values: [id: id],
      expression_attribute_names: %{"#id" => "id"},
      key_condition_expression: "#id = :id"
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: Post)

    Enum.at(result, 0)
  end
end
