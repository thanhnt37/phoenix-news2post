defmodule News2PostWeb.ApiJSON do

  alias News2Post.CRUD.Post
  alias News2Post.CRUD.News

  def get_posts(%{posts: posts}) do
    response(%{code: 200, message: "Successful!", data: for(post <- posts, do: post_detail(post))})
  end

  def show_post(%{post: post}) do
    response(%{code: 200, message: "Successful", data: post_detail(post)})
  end

  def response(data) do
    %{
      code: data.code,
      message: data.message,
      data: data.data
    }
  end

  def get_news(%{news: news}) do
    response(%{code: 200, message: "Successful!", data: for(record <- news, do: news_detail(record))})
  end

  def show_news(%{news: news}) do
    response(%{code: 200, message: "Successful", data: news_detail(news)})
  end

  defp post_detail(%Post{} = post) do
    %{
      id: post.id,
      title: post.title,
      description: post.description,
      sections: post.sections,
      status: post.status,
      url: post.url,
      created_at: post.created_at
    }
  end

  defp news_detail(%News{} = news) do
    %{
      id: news.id,
      title: news.title,
      description: news.description,
      url: news.url,
      status: news.status,
      published_at: news.created_at,
      created_at: news.created_at
    }
  end
end