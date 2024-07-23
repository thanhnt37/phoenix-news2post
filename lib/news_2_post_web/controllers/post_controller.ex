defmodule News2PostWeb.PostController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.Post
  alias ExAws.Dynamo

  def index(conn, _params) do
    status = Map.get(conn.params, "status", "all")
    last_evaluated_key = Map.get(conn.params, "k", "{}")
    page_type = Map.get(conn.params, "t", "next")
    last_evaluated_key = JSON.decode!(last_evaluated_key)
    IO.puts("..... query string: #{inspect(conn.params, pretty: true)}")

    posts = CRUD.get_posts_v2(status, 10, page_type, last_evaluated_key)
#    IO.puts("..... posts: #{inspect(posts, pretty: true)}")

    previous_key =
      if page_type == "next" && last_evaluated_key == %{} do
        "{}"
      else
        JSON.encode!(posts.previous_key)
      end

    render(conn, :index,
      posts: posts, status: status,
      last_evaluated_key: JSON.encode!(last_evaluated_key), page_type: page_type,
      next_key: JSON.encode!(posts.next_key), previous_key: previous_key
    )
  end

  def show(conn, %{"sk" => sk}) do
    post = CRUD.get_post_by_id(sk)
    sections = JSON.decode!(post.sections)

    render(conn, :show, post: post, sections: sections)
  end

  def edit(conn, %{"sk" => sk}) do
    post = CRUD.get_post_by_id(sk)
    sections = JSON.decode!(post.sections)

    render(conn, :edit, post: post, sections: sections)
  end

  def update(conn, %{"sk" => sk, "post" => post_params}) do
    post = CRUD.get_post_by_id(sk)

    sections = Map.values(post_params["sections"])
    sections = JSON.encode!(sections)

    updated_data = %{post_params | "sections" => sections}
    CRUD.update_post(
      post.sk,
      %{:title => updated_data["title"], :description => updated_data["description"], :sections => updated_data["sections"]}
    )

    conn
    |> put_flash(:info, "Post updated successfully.")
    |> redirect(to: ~p"/posts/#{post}")
  end

  def approve(conn, params) do
    referer_url = Plug.Conn.get_req_header(conn, "referer")
                  |> List.first()

    post = CRUD.get_post_by_id(params["sk"])
    # TODO: validation
    CRUD.update_post(post.sk, %{:status => "approved"})

    conn
    |> put_flash(:info, "Post approved successfully.")
    |> redirect(external: referer_url)
  end

  def publish(conn, params) do
    referer_url = Plug.Conn.get_req_header(conn, "referer")
                  |> List.first()

    user = conn.assigns[:current_user]
    configs = if user.configs == "", do: "{}", else: user.configs
    configs = JSON.decode!(configs)
    if configs == %{} do
      conn
      |> put_flash(:error, "Missing WordPress configurations")
      |> redirect(external: referer_url)
    end

    post = CRUD.get_post_by_id(params["sk"])
    case send_request_to_wp(configs, post) do
      {:ok, body} ->
        # TODO: validation
        CRUD.update_post(post.sk, %{:status => "published"})
        conn
        |> put_flash(:info, "Post published successfully.")
        |> redirect(external: referer_url)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(external: referer_url)
    end
  end

  def delete(conn, %{"sk" => sk}) do
    post = CRUD.get_post_by_id(sk)
    CRUD.delete_post(post.sk)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  def send_request_to_wp(configs, post) do
    endpoint = configs["endpoint"]
    username = configs["username"]
    password = configs["app_password"]
    url = "#{endpoint}/wp-json/wp/v2/posts"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", basic_auth_header(username, password)}
    ]
    body = Jason.encode!(%{
      title: post.title,
      content: post.title,
      status: "publish"
    })

    case :hackney.request(:post, url, headers, body, [recv_timeout: 5000]) do
      {:ok, status_code, _headers, client_ref} when status_code in 200..299 ->
        {:ok, body} = :hackney.body(client_ref)
        {:ok, body}

      {:ok, status_code, _headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        {:error, "Request failed with status code: #{status_code}."}

      {:error, reason} ->
        {:error, "Request failed with reason: #{reason}"}
    end
  end

  defp basic_auth_header(username, password) do
    encoded = Base.encode64("#{username}:#{password}")
    "Basic #{encoded}"
  end

end
