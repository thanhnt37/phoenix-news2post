defmodule News2Post.CRUD.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :preamble, :string
    field :sections, :string
    field :status, :string  # raw || reviewing || approved || published
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :preamble, :sections, :status, :url])
    |> validate_required([:title, :preamble, :sections])
  end
end
