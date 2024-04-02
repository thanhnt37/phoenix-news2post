defmodule News2Post.CRUD.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :description, :string
    field :sections, :string
    field :status, :string  # raw || reviewing || approved || published
    field :url, :string

    timestamps(type: :utc_datetime, inserted_at: :created_at, updated_at: :updated_at)
  end

  def changeset(post, attrs \\ %{}) do
    post
    |> cast(attrs, [:title, :description, :sections, :status, :url])
    |> validate_required([:title, :description, :sections, :url])
  end

end
