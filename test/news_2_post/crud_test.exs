defmodule News2Post.CRUDTest do
  use News2Post.DataCase

  alias News2Post.CRUD

  describe "news" do
    alias News2Post.CRUD.News

    import News2Post.CRUDFixtures

    @invalid_attrs %{title: nil, preamble: nil, sections: nil}

    test "list_news/0 returns all news" do
      news = news_fixture()
      assert CRUD.list_news() == [news]
    end

    test "get_news!/1 returns the news with given id" do
      news = news_fixture()
      assert CRUD.get_news!(news.id) == news
    end

    test "create_news/1 with valid data creates a news" do
      valid_attrs = %{title: "some title", preamble: "some preamble", sections: "some sections"}

      assert {:ok, %News{} = news} = CRUD.create_news(valid_attrs)
      assert news.title == "some title"
      assert news.preamble == "some preamble"
      assert news.sections == "some sections"
    end

    test "create_news/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CRUD.create_news(@invalid_attrs)
    end

    test "update_news/2 with valid data updates the news" do
      news = news_fixture()
      update_attrs = %{title: "some updated title", preamble: "some updated preamble", sections: "some updated sections"}

      assert {:ok, %News{} = news} = CRUD.update_news(news, update_attrs)
      assert news.title == "some updated title"
      assert news.preamble == "some updated preamble"
      assert news.sections == "some updated sections"
    end

    test "update_news/2 with invalid data returns error changeset" do
      news = news_fixture()
      assert {:error, %Ecto.Changeset{}} = CRUD.update_news(news, @invalid_attrs)
      assert news == CRUD.get_news!(news.id)
    end

    test "delete_news/1 deletes the news" do
      news = news_fixture()
      assert {:ok, %News{}} = CRUD.delete_news(news)
      assert_raise Ecto.NoResultsError, fn -> CRUD.get_news!(news.id) end
    end

    test "change_news/1 returns a news changeset" do
      news = news_fixture()
      assert %Ecto.Changeset{} = CRUD.change_news(news)
    end
  end

  describe "posts" do
    alias News2Post.CRUD.Post

    import News2Post.CRUDFixtures

    @invalid_attrs %{status: nil, title: nil, url: nil, preamble: nil, sections: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert CRUD.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert CRUD.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{status: "some status", title: "some title", url: "some url", preamble: "some preamble", sections: "some sections"}

      assert {:ok, %Post{} = post} = CRUD.create_post(valid_attrs)
      assert post.status == "some status"
      assert post.title == "some title"
      assert post.url == "some url"
      assert post.preamble == "some preamble"
      assert post.sections == "some sections"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CRUD.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{status: "some updated status", title: "some updated title", url: "some updated url", preamble: "some updated preamble", sections: "some updated sections"}

      assert {:ok, %Post{} = post} = CRUD.update_post(post, update_attrs)
      assert post.status == "some updated status"
      assert post.title == "some updated title"
      assert post.url == "some updated url"
      assert post.preamble == "some updated preamble"
      assert post.sections == "some updated sections"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = CRUD.update_post(post, @invalid_attrs)
      assert post == CRUD.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = CRUD.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> CRUD.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = CRUD.change_post(post)
    end
  end
end
