defmodule News2Post.CRUDFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `News2Post.CRUD` context.
  """

  @doc """
  Generate a news.
  """
  def news_fixture(attrs \\ %{}) do
    {:ok, news} =
      attrs
      |> Enum.into(%{
        preamble: "some preamble",
        sections: "some sections",
        title: "some title"
      })
      |> News2Post.CRUD.create_news()

    news
  end

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        preamble: "some preamble",
        sections: "some sections",
        status: "some status",
        title: "some title",
        url: "some url"
      })
      |> News2Post.CRUD.create_post()

    post
  end
end
