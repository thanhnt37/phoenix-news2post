defmodule News2Post.CRUD.News do
  use Ecto.Schema
  import Ecto.Changeset

  schema "news" do
    field :title, :string
    field :preamble, :string
    field :sections, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(news, attrs) do
    news
    |> cast(attrs, [:title, :preamble, :sections])
    |> validate_required([:title, :preamble, :sections])
  end
end