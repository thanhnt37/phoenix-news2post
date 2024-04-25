defmodule News2Post.CRUD do
  import Ecto.Query, warn: false
  alias ExAws.Dynamo
  alias News2Post.Repo

  alias News2Post.CRUD.News
  alias News2Post.CRUD.Post

  @news_table_name "news2post_dev_single_table"
  @posts_table_name "news2post_dev_single_table"

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

  def create_news(attr) do
    IO.inspect(attr)

    Dynamo.put_item(@news_table_name, attr)
    |> ExAws.request!
  end

  def get_news_by_id(id) do
    records = Dynamo.query(
               @news_table_name,
               expression_attribute_values: [id: id],
               expression_attribute_names: %{"#id" => "id"},
               key_condition_expression: "#id = :id"
             )
             |> ExAws.request!
             |> Dynamo.decode_item(as: News)

    Enum.at(records, 0)
  end

  def delete_news(id, created_at) do
    Dynamo.delete_item(
      @news_table_name,
      %{id: id, created_at: created_at}
    )
    |> ExAws.request!
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

  def get_posts_v2(status \\ "all", limit \\ 10, page_type \\ "next", last_evaluated_key \\ %{}) do
    opts = %{
      limit: limit,
      expression_attribute_values: [pk: "posts"],
      expression_attribute_names: %{"#pk" => "pk"},
      key_condition_expression: "#pk = :pk"
    }

    if status != "all" do

    end

    opts =
      if is_map(last_evaluated_key) and last_evaluated_key != %{} do
        Map.put(opts, :exclusive_start_key, last_evaluated_key)
      else
        opts
      end

    IO.puts("..... page_type: #{inspect(page_type, pretty: true)}")
    opts =
      if page_type == "previous" do
        Map.put(opts, :scan_index_forward, true)
      else
        Map.put(opts, :scan_index_forward, false)
      end

    #    if is_map(last_evaluated_key) and last_evaluated_key != %{} do
##      Map.put(opts, :exclusive_start_key, last_evaluated_key)
#      opts = opts | %{exclusive_start_key: last_evaluated_key}
#      IO.puts("..... last_evaluated_key: #{inspect(last_evaluated_key, pretty: true)}")
#      IO.puts("..... opts: #{inspect(opts, pretty: true)}")
#    end

    IO.puts("..... opts 2: #{inspect(opts, pretty: true)}")

    Dynamo.query(@posts_table_name, opts)
    |> ExAws.request!
    |> inspect_response()
    |> handle_response(opts)
#    |> Dynamo.decode_item(as: Post)
  end

  def get_post_by_id(id) do
    records = Dynamo.query(
                @posts_table_name,
                expression_attribute_values: [pk: "posts", sk: id],
                expression_attribute_names: %{"#pk" => "pk", "#sk" => "sk"},
                key_condition_expression: "#pk = :pk AND #sk = :sk"
             )
             |> ExAws.request!
             |> Dynamo.decode_item(as: Post)

    Enum.at(records, 0)
  end

  def delete_post(id) do
    Dynamo.delete_item(
      @posts_table_name,
      %{pk: "posts", sk: id}
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
  def update_post(id, updated_data) do
    update_expression = build_update_expression(updated_data)

    expression_attribute_names = build_expression_attribute_names(updated_data)

    expression_attribute_values = build_expression_attribute_values(updated_data)

    primary_key = %{pk: "posts", sk: id}

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

  defp inspect_response(response) do
#    IO.puts("..... response: #{inspect(response, pretty: true)}")
    response
  end

  def handle_response(%{"Items" => items_data, "Count" => count, "LastEvaluatedKey" => last_key, "ScannedCount" => scanned_count}, opts) do
    IO.puts("..... handle_response 2")
    IO.puts("..... items: #{inspect(items_data, pretty: true)}")
    IO.puts("..... count: #{inspect(count, pretty: true)}")
    IO.puts("..... last_key: #{inspect(last_key, pretty: true)}")
    items = Enum.map(items_data, &Dynamo.decode_item(&1, as: Post))
    items = Enum.sort_by(items, & &1.sk, :desc)
    last_key = last_key |> Dynamo.decode_item(as: Post)

    next_key =
      if count == 0 do
        if opts.scan_index_forward do
          opts.exclusive_start_key
        else
          %{}
        end
      else
        last_item = Enum.at(items, -1)
        %{
          pk: last_item.pk,
          sk: last_item.sk
        }
      end

    previous_key =
      if count == 0 do
        if opts.scan_index_forward do
          %{}
        else
          opts.exclusive_start_key
        end
      else
        first_item = List.first(items)
        %{
          pk: first_item.pk,
          sk: first_item.sk
        }
      end

#    if count == 0 do
#      if opts.scan_index_forward do
#        previous_key = %{
#          pk: last_key.pk,
#          sk: last_key.sk
#        }
#        next_key = %{}
#      else
#        previous_key = %{}
#        next_key = %{
#          pk: last_key.pk,
#          sk: last_key.sk
#        }
#      end
#    else
#      items = Enum.sort_by(items, & &1.sk, :desc)
#      first_item = List.first(items)
#      last_item = Enum.at(items, -1)
#      previous_key = %{
#        pk: first_item.pk,
#        sk: first_item.sk
#      }
#      next_key = %{
#        pk: last_item.pk,
#        sk: last_item.sk
#      }
#    end

    IO.puts("..... opts: #{inspect(opts, pretty: true)}")
    IO.puts("..... scan_index_forward: #{inspect(opts.scan_index_forward, pretty: true)}")

    IO.puts("..... previous_key: #{inspect(previous_key, pretty: true)}")
    IO.puts("..... next_key: #{inspect(next_key, pretty: true)}")
#    IO.puts("..... last_key: #{inspect(last_key, pretty: true)}")
#    IO.puts("..... exclusive_start_key: #{inspect(opts.exclusive_start_key, pretty: true)}")

    %{
      items: items,
      count: count,
      last_evaluated_key: last_key,
      next_key: next_key,
      previous_key: previous_key,
      scanned_count: scanned_count
    }
  end

  def handle_response(%{"Items" => items_data, "Count" => count, "ScannedCount" => scanned_count}, opts) do
    IO.puts("..... handle_response 1")
    handle_response(%{
      "Items" => items_data,
      "Count" => count,
      "LastEvaluatedKey" => %{},  # Giả sử giá trị mặc định là nil
      "ScannedCount" => scanned_count
    }, opts)
  end

end
