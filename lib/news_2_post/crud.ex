defmodule News2Post.CRUD do
  import Ecto.Query, warn: false
  alias ExAws.Dynamo
  alias News2Post.Repo

  alias News2Post.CRUD.News
  alias News2Post.CRUD.Post

  @news_table_name "news2post_dev_News_v2"
  @posts_table_name "news2post_dev_Posts_v2"

#  --------------------- News ---------------------

  def all_news() do
    Dynamo.scan(
      @news_table_name
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: News)
  end

  def get_news(limit \\ 10) do
    Dynamo.scan(
      @news_table_name,
      limit: limit
    )
    |> ExAws.request!
    |> Dynamo.decode_item(as: News)
  end

#  --------------------- Posts ---------------------
  def all_posts(status \\ "all") do
    opts =
      if status != "all" do
        %{
          limit: 50,
          expression_attribute_values: [status: status],
          expression_attribute_names: %{"#status" => "status"},
          filter_expression: "#status = :status"
        }
      else
        %{ limit: 50 }
      end
    IO.inspect(opts)

    Dynamo.scan(@posts_table_name, opts)
    |> ExAws.request!
    |> Dynamo.decode_item(as: Post)
  end
  
  def create_post(attr) do
    IO.inspect(attr)

    Dynamo.put_item(@posts_table_name, attr)
    |> ExAws.request!
  end

  def get_posts(status \\ "all", limit \\ 10) do
    opts =
      if status != "all" do
        %{
          limit: limit,
          expression_attribute_values: [status: status],
          expression_attribute_names: %{"#status" => "status"},
          filter_expression: "#status = :status"
        }
      else
        %{ limit: limit }
      end
    IO.inspect(opts)

    Dynamo.scan(@posts_table_name, opts)
    |> ExAws.request!
    |> Dynamo.decode_item(as: Post)
  end

  def get_post_by_id(id) do
    result = Dynamo.query(
               @posts_table_name,
               expression_attribute_values: [id: id],
               expression_attribute_names: %{"#id" => "id"},
               key_condition_expression: "#id = :id"
             )
             |> ExAws.request!
             |> Dynamo.decode_item(as: Post)

    Enum.at(result, 0)
  end

  def delete_post(id, created_at) do
    Dynamo.delete_item(
      @posts_table_name,
      %{id: id, created_at: created_at}
    )
    |> ExAws.request!
  end

  # ## Parameters
  #
  # - `id`: String
  # - `created_at`: String
  # - `updated_data`: Map
  #   + `title`: String (Optional)
  #   + `description`: String (Optional)
  #   + `sections`: String (Optional)
  #
  # ## Example
  #     iex> PostCRUD.update_post("123", "2022-01-01T00:00:00Z", %{title: "New Title", description: "New Description"})
  def update_post(id, created_at, updated_data) do
    update_expression = build_update_expression(updated_data)

    expression_attribute_names = build_expression_attribute_names(updated_data)

    expression_attribute_values = build_expression_attribute_values(updated_data)

    primary_key = %{id: id, created_at: created_at}

    update_item_params = %{
      update_expression: update_expression,
      expression_attribute_names: expression_attribute_names,
      expression_attribute_values: expression_attribute_values,
      return_values: :updated_new
    }

    IO.puts("..... update_item_params: #{inspect(update_item_params, pretty: true)}")

    Dynamo.update_item(@posts_table_name, primary_key, update_item_params)
    |> ExAws.request!()
  end

#  --------------------- PRIVATE ---------------------

  defp build_update_expression(updated_data) do
    expressions =
      Enum.map(
        updated_data,
        fn {key, _} -> "##{key} = :#{key}" end
      )

    update_expression =
      Enum.join(expressions, ", ")

    "SET #{update_expression}"
  end

  defp build_expression_attribute_names(updated_data) do
    attribute_names =
      Enum.map(
        updated_data,
        fn {key, _} -> {"##{key}", key} end
      )

    Map.new(attribute_names)
  end

  defp build_expression_attribute_values(updated_data) do
    Enum.reduce(
      updated_data,
      %{},
      fn {key, value}, acc ->
        Map.put(acc, :"#{key}", value)
      end
    )
  end

end
