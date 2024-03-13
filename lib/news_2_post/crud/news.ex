defmodule News2Post.CRUD.News do
  use Ecto.Schema
  import Ecto.Changeset

  schema "news" do
    field :title, :string
    field :preamble, :string
    field :sections, :string
    field :status, :string  # raw || reviewing || approved || published
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(news, attrs) do
    news
    |> cast(attrs, [:title, :preamble, :sections, :status, :url])
    |> validate_required([:title, :preamble, :sections])
  end
end
