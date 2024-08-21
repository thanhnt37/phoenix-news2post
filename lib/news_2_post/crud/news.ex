defmodule News2Post.CRUD.News do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:sk, :binary_id, autogenerate: true}
  schema "news" do
    field :pk, :string
    field :title, :string
    field :description, :string
    field :url, :string
    field :status, :string  # creating | raw || re_writing || rewrote
    field :progress, :string  # 25%
    field :published_at, :date
    field :post_id, :string

    timestamps(type: :utc_datetime, inserted_at: :created_at, updated_at: :updated_at)
  end

  @doc false
  def changeset(news, attrs) do
    news
    |> cast(attrs, [:title, :description, :url, :status, :progress, :published_at])
    |> validate_required([:title, :description, :url, :published_at])
  end

  defimpl Phoenix.Param, for: News2Post.CRUD.News do
    def to_param(%{sk: sk}), do: sk
  end

end
