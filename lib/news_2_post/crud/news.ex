defmodule News2Post.CRUD.News do
  use Ecto.Schema
  import Ecto.Changeset

  schema "news" do
    field :title, :string
    field :description, :string
    field :url, :string
    field :status, :string  # raw
    field :published_at, :date

    timestamps(type: :utc_datetime, inserted_at: :created_at, updated_at: :updated_at)
  end

  @doc false
  def changeset(news, attrs) do
    news
    |> cast(attrs, [:title, :description, :url, :status, :published_at])
    |> validate_required([:title, :description, :url])
  end
end
