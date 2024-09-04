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
    if post == nil do
      conn
      |> put_flash(:error, "Post does not exist!")
      |> redirect(to: ~p"/posts")
    end
    sections = post.sections && JSON.decode!(post.sections) || []

    render(conn, :show, post: post, sections: sections)
  end

  def edit(conn, %{"sk" => sk}) do
    post = CRUD.get_post_by_id(sk)
    sections = post.sections && JSON.decode!(post.sections) || []

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
    integration_type = Map.get(configs, "integration_type", "")
    if configs == %{} || integration_type == "" do
      conn
      |> put_flash(:error, "Missing CMS Platform configurations!")
      |> redirect(external: referer_url)
    end

    post = CRUD.get_post_by_id(params["sk"])
    if integration_type == "wordpress" do
      case send_request_to_wordpress(configs, post) do
        {:ok, body} ->
          CRUD.update_post(post.sk, %{:status => "published"})
          conn
          |> put_flash(:info, "Post published to WordPress successfully.")
          |> redirect(external: referer_url)
        {:error, reason} ->
          conn
          |> put_flash(:error, reason)
          |> redirect(external: referer_url)
      end
    else
      if integration_type == "webflow" do
        case send_request_to_webflow(configs, post) do
          {:ok, body} ->
            CRUD.update_post(post.sk, %{:status => "published"})
            conn
            |> put_flash(:info, "Post published to WebFlow successfully.")
            |> redirect(external: referer_url)
          {:error, reason} ->
            conn
            |> put_flash(:error, reason)
            |> redirect(external: referer_url)
        end
      end
    end

    conn
    |> put_flash(:error, "Bad request parameters.")
    |> redirect(external: referer_url)
  end

  def delete(conn, %{"sk" => sk}) do
    post = CRUD.get_post_by_id(sk)
    IO.puts("............. deleting post_id: #{sk}")
    CRUD.delete_post(post.sk)
    news_id = post.news_id
    IO.puts("............. deleting news_id: #{news_id}")
    CRUD.update_news(news_id, %{:status => "raw"})

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  defp send_request_to_webflow(configs, post) do
    token = configs["webflow"]["token"]
    collection_id = configs["webflow"]["collection_id"]
    url = "https://api.webflow.com/v2/collections/#{collection_id}/items"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]
    sections = JSON.decode!(post.sections)
    post_content = sections
                   |> Enum.map(fn %{"heading" => heading, "text" => text} -> "<h2>#{heading}</h2> <p>#{text}</p>" end)
                   |> Enum.join(" ")
    body = Jason.encode!(%{
      isArchived: false,
      isDraft: true,
      fieldData: %{
        "name": post.title,
        "post-body": post_content,
        "post-summary": post.description,
      }
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

  defp send_request_to_wordpress(configs, post) do
    endpoint = configs["wordpress"]["endpoint"]
    username = configs["wordpress"]["username"]
    password = configs["wordpress"]["app_password"]
    url = "#{endpoint}/wp-json/wp/v2/posts"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", basic_auth_header(username, password)}
    ]
    sections = JSON.decode!(post.sections)
    post_content = sections
                   |> Enum.map(fn %{"heading" => heading, "text" => text} -> "<h2>#{heading}</h2> <p>#{text}</p>" end)
                   |> Enum.join(" ")
    body = Jason.encode!(%{
      title: post.title,
      content: post_content,
      status: "draft"
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
