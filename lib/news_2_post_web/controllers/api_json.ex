defmodule News2PostWeb.ApiJSON do

  alias News2Post.CRUD.Post

  def index(%{posts: posts}) do
    response(%{code: 200, message: "Successful!", data: for(post <- posts, do: data(post))})
  end

  def show(%{post: post}) do
    response(%{code: 200, message: "Successful", data: data(post)})
  end

  def response(data) do
    %{
      code: data.code,
      message: data.message,
      data: data.data
    }
  end

  defp data(%Post{} = post) do
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
end