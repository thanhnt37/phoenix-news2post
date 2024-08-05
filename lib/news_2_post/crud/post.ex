defmodule News2Post.CRUD.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:sk, :binary_id, autogenerate: true}
  schema "posts" do
    field :pk, :string
    field :title, :string
    field :description, :string
    field :sections, :string
    field :status, :string  # reviewing || approved || published
    field :url, :string
    field :news_id, :string

    timestamps(type: :utc_datetime, inserted_at: :created_at, updated_at: :updated_at)
  end

  def changeset(post, attrs \\ %{}) do
    post
    |> cast(attrs, [:title, :description, :sections, :status, :url])
    |> validate_required([:title, :description, :sections, :url])
  end

  defimpl Phoenix.Param, for: News2Post.CRUD.Post do
    def to_param(%{sk: sk}), do: sk
  end

end
