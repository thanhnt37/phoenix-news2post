defmodule News2PostWeb.NewsController do
  use News2PostWeb, :controller

  alias News2Post.CRUD
  alias News2Post.CRUD.News

  def index(conn, _params) do
    news = CRUD.list_news()
    render(conn, :index, news_collection: news)
  end

  def new(conn, _params) do
    changeset = CRUD.change_news(%News{})
    render(conn, :new, changeset: changeset)


  end

  def approve(conn, params) do
    status = %{
      "status" => "approved"
    }
    IO.puts("status: #{inspect(status, pretty: true)}")

    news = CRUD.get_news!(params["id"])
    case CRUD.update_news(news, status) do
      {:ok, _news} ->
        conn
        |> put_flash(:info, "News Approved successfully.")
        |> redirect(to: ~p"/news")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, news: news, changeset: changeset)
    end
  end

  def create(conn, %{"news" => news_params}) do
    case CRUD.create_news(news_params) do
      {:ok, news} ->
        conn
        |> put_flash(:info, "News created successfully.")
        |> redirect(to: ~p"/news/#{news}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    news = CRUD.get_news!(id)
    IO.inspect(news.sections)
    IO.puts("news.sections: #{inspect(news.sections, pretty: true)}")

    sections = JSON.decode!(news.sections)
    IO.puts("sections: #{inspect(sections, pretty: true)}")

    render(conn, :show, news: news, sections: sections)
  end

  def edit(conn, %{"id" => id}) do
    news = CRUD.get_news!(id)
    changeset = CRUD.change_news(news)
    sections = JSON.decode!(news.sections)
    IO.puts("sections: #{inspect(sections, pretty: true)}")

    render(conn, :edit, news: news, changeset: changeset, sections: sections)
  end

  def update(conn, %{"id" => id, "news" => news_params}) do
    news = CRUD.get_news!(id)

    sections = Map.values(news_params["sections"])
    sections = JSON.encode!(sections)

    updated_data = %{news_params | "sections" => sections}
    IO.puts("updated_data: #{inspect(updated_data, pretty: true)}")
    IO.inspect("is_map updated_data: #{is_map(updated_data)}")

    case CRUD.update_news(news, updated_data) do
      {:ok, news} ->
        conn
        |> put_flash(:info, "News updated successfully.")
        |> redirect(to: ~p"/news/#{news}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, news: news, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news = CRUD.get_news!(id)
    {:ok, _news} = CRUD.delete_news(news)

    conn
    |> put_flash(:info, "News deleted successfully.")
    |> redirect(to: ~p"/news")
  end
end
