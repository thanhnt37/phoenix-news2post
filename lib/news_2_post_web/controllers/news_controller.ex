defmodule News2PostWeb.NewsController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News

  def index(conn, _params) do
    page_size = 10
    last_evaluated_key = Map.get(conn.params, "k", "{}")
    page_type = Map.get(conn.params, "t", "next")
    last_evaluated_key = JSON.decode!(last_evaluated_key)
    IO.puts("..... query string: #{inspect(conn.params, pretty: true)}")

    news = CRUD.get_news_v2(page_size, page_type, last_evaluated_key)

    previous_key =
      if page_type == "next" && last_evaluated_key == %{} do
        "{}"
      else
        JSON.encode!(news.previous_key)
      end

    render(conn, :index,
      news_collection: news,
      last_evaluated_key: JSON.encode!(last_evaluated_key), page_type: page_type,
      next_key: JSON.encode!(news.next_key), previous_key: previous_key
    )
  end

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"url" => url}) do
    referer_url = Plug.Conn.get_req_header(conn, "referer")
                  |> List.first()

    if valid_domain?(url) do
      news_id = UUID.uuid1()
      record = %{
        "pk": "news",
        "sk": news_id,
        "url": url,
        "status": "raw",
        "created_at": DateTime.to_string(DateTime.utc_now()),
      }
      IO.puts("..... record: #{inspect(record, pretty: true)}")

      CRUD.create_news(record)
      news = CRUD.get_news_by_id(news_id)
      conn
      |> put_flash(:info, "Create News successfully")
      |> redirect(to: ~p"/news/#{news}")
    else
      conn
      |> put_flash(:error, "Please use posts from mynewsdesk.com")
      |> redirect(external: referer_url)
    end

  end

  def show(conn, %{"sk" => sk}) do
    news = CRUD.get_news_by_id(sk)

    render(conn, :show, news: news)
  end

  def re_write(conn, params) do
    referer_url = Plug.Conn.get_req_header(conn, "referer")
                  |> List.first()

    news = CRUD.get_news_by_id(params["sk"])
    request_data = %{
      pk: news.pk,
      sk: news.sk,
      url: news.url
    }
    {:ok, request_data_json} = Jason.encode(request_data)
    project_root = :code.priv_dir(:news_2_post) |> Path.join("../../")
    file_path = Path.join([project_root, "urls/scrapy/waiting", "#{news.sk}.json"])
    File.mkdir_p!(Path.dirname(file_path))
    File.write(file_path, request_data_json)

    # TODO: validation
    CRUD.update_news(news.sk, %{:status => "re_writing"})

    conn
    |> put_flash(:info, "Send request successfully.")
    |> redirect(external: referer_url)
  end

  defp valid_domain?(url) do
    with %URI{host: host} <- URI.parse(url),
         true <- host_valid?(host) do
      true
    else
      _ -> false
    end
  end

  defp host_valid?(host) when is_binary(host) do
    String.ends_with?(host, "mynewsdesk.com")
  end

end
