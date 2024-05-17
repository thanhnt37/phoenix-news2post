defmodule News2Post.CRUD.Stats do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:sk, :binary_id, autogenerate: true}
  schema "stats" do
    field :pk, :string
    field :today, :string
    field :this_month, :string
    field :this_quarter, :string
    field :this_year, :string

    timestamps(type: :utc_datetime, inserted_at: :created_at, updated_at: :updated_at)
  end

  @doc false
  def changeset(stats, attrs) do
    stats
    |> cast(attrs, [:pk, :sk, :today, :this_month, :this_quarter, :this_year])
    |> validate_required([:pk, :sk, :today, :this_month, :this_quarter, :this_year])
  end

  defimpl Phoenix.Param, for: News2Post.CRUD.News do
    def to_param(%{sk: sk}), do: sk
  end

end
