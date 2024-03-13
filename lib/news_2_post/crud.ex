defmodule News2Post.CRUD do
  @moduledoc """
  The CRUD context.
  """

  import Ecto.Query, warn: false
  alias News2Post.Repo

  alias News2Post.CRUD.News

  @doc """
  Returns the list of news.

  ## Examples

      iex> list_news()
      [%News{}, ...]

  """
  def list_news(status) do
    news_query =
      if status == "all" do
        News
      else
        News |> where([i], i.status == ^status)
      end

    news_query
      |> order_by([i], desc: i.status)
      |> order_by([i], desc: i.id)
      |> Repo.all()
  end

  def all_news() do
    News
      |> order_by([i], desc: i.id)
      |> Repo.all()
  end

  @doc """
  Gets a single news.

  Raises `Ecto.NoResultsError` if the News does not exist.

  ## Examples

      iex> get_news!(123)
      %News{}

      iex> get_news!(456)
      ** (Ecto.NoResultsError)

  """
  def get_news!(id), do: Repo.get!(News, id)

  @doc """
  Creates a news.

  ## Examples

      iex> create_news(%{field: value})
      {:ok, %News{}}

      iex> create_news(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_news(attrs \\ %{}) do
    %News{}
    |> News.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a news.

  ## Examples

      iex> update_news(news, %{field: new_value})
      {:ok, %News{}}

      iex> update_news(news, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_news(%News{} = news, attrs) do
    news
    |> News.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a news.

  ## Examples

      iex> delete_news(news)
      {:ok, %News{}}

      iex> delete_news(news)
      {:error, %Ecto.Changeset{}}

  """
  def delete_news(%News{} = news) do
    Repo.delete(news)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking news changes.

  ## Examples

      iex> change_news(news)
      %Ecto.Changeset{data: %News{}}

  """
  def change_news(%News{} = news, attrs \\ %{}) do
    News.changeset(news, attrs)
  end

  alias News2Post.CRUD.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(status) do
    news_query =
      if status == "all" do
        Post
      else
        Post |> where([i], i.status == ^status)
      end

    news_query
    |> order_by([i], desc: i.status)
    |> order_by([i], desc: i.id)
    |> Repo.all()
  end

  def all_posts() do
    Post
    |> order_by([i], desc: i.id)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
