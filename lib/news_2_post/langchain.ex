defmodule News2Post.Langchain do
  use GenServer

  alias News2Post.CRUD

  @waiting_folder "../urls/dynamodb/waiting"
  @processed_folder "../urls/dynamodb/processed"
  @tmp_folder "../urls/dynamodb/tmp"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    read_and_process_files()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 120_000)
  end

  defp read_and_process_files() do
    files = File.ls!(@waiting_folder)
            |> Enum.filter(&String.ends_with?(&1, ".json"))

    Enum.each(files, fn file ->
      file_path = Path.join(@waiting_folder, file)
      news_id = Path.basename(file, ".json")
      new_post_id = UUID.uuid1()
      file_content = File.read!(file_path)
      data = Jason.decode!(file_content)
      sections = Jason.encode!(data["sections"])
      record = %{
        "pk": "posts",
        "sk": new_post_id,
        "title": data["title"],
        "description": data["description"],
        "url": data["url"],
        "sections": sections,
        "status": "reviewing",
        "created_at": DateTime.to_string(DateTime.utc_now()),
        "news_id": news_id
      }
#      IO.puts("record: #{inspect(record, pretty: true)}")

      CRUD.create_post(record)
      move_file_to_processed_folder(file_path, file)

      CRUD.update_news(
        news_id,
        %{
          :title => data["title"],
          :description => data["description"],
          :status => "rewrote",
          :post_id => new_post_id,
        }
      )
    end)

    handle_tmp_message()
  end

  defp handle_tmp_message() do
    files = File.ls!(@tmp_folder)
            |> Enum.filter(&String.ends_with?(&1, ".json"))

    Enum.each(files, fn file ->
      file_path = Path.join(@tmp_folder, file)
      IO.puts("..... handle tmp message: #{file_path}")
      news_id = Path.basename(file, ".json")
      file_content = File.read!(file_path)
      data = Jason.decode!(file_content)
      CRUD.update_news(
        news_id,
        %{
          :title => data["title"],
          :description => data["first_paragraph"],
          :published_at => data["published_date"],
          "status": "raw",
          "progress": "100%",
        }
      )

      File.rm(file_path)
    end)
  end

  defp move_file_to_processed_folder(file_path, file_name) do
    ensure_processed_folder_exists()

    target_path = Path.join(@processed_folder, file_name)
    File.rename(file_path, target_path)
  end

  defp ensure_processed_folder_exists() do
    unless File.exists?(@processed_folder) do
      File.mkdir_p!(@processed_folder)
    end
  end

end
