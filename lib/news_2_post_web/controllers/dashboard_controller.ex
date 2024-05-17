defmodule News2PostWeb.DashboardController do
  use News2PostWeb, :controller
  alias News2Post.CRUD
  alias News2Post.DateHelpers

  def index(conn, _params) do
    current_date = Date.utc_today()
    formatted_date = format_date(current_date)

    stats = CRUD.get_stats_news()
    news_stats =
      if stats == nil do
        tmp_stats = stats_news(%{});
        CRUD.create_stats_news(tmp_stats)
        tmp_stats
      else
        stats
      end

    stats = CRUD.get_stats_posts()
    posts_stats =
      if stats == nil do
        tmp_stats = stats_posts(%{});
        CRUD.create_stats_posts(tmp_stats)
        tmp_stats
      else
        stats
      end

    news = CRUD.get_news_v2(5, "next", %{})
    posts = CRUD.get_posts_v2("all", 5, "next", %{})
    collection = Enum.concat(posts.items, news.items)
    collection = Enum.sort_by(collection, & &1.sk, &>=/2)

    render(conn, :index, news_collection: collection, formatted_date: formatted_date, news_stats: news_stats, posts_stats: posts_stats)
  end

  defp stats_news(last_key, stats \\ %{}) do
    news = CRUD.get_news_v2(100, "next", last_key)
    new_stats = count_items(news.items)

    total_stats = %{
      today: new_stats.today + Map.get(stats, :today, 0),
      this_month: new_stats.this_month + Map.get(stats, :this_month, 0),
      this_quarter: new_stats.this_quarter + Map.get(stats, :this_quarter, 0),
      this_year: new_stats.this_year + Map.get(stats, :this_year, 0)
    }

    if news.last_evaluated_key != %{} && news.last_evaluated_key.sk != nil do
      stats_news(news.last_evaluated_key, total_stats)
    else
      total_stats
    end
  end

  defp stats_posts(last_key, stats \\ %{}) do
    posts = CRUD.get_posts_v2("all", 100, "next", last_key)
    new_stats = count_items(posts.items)

    total_stats = %{
      today: new_stats.today + Map.get(stats, :today, 0),
      this_month: new_stats.this_month + Map.get(stats, :this_month, 0),
      this_quarter: new_stats.this_quarter + Map.get(stats, :this_quarter, 0),
      this_year: new_stats.this_year + Map.get(stats, :this_year, 0)
    }

    if posts.last_evaluated_key != %{} && posts.last_evaluated_key.sk != nil do
      stats_posts(posts.last_evaluated_key, total_stats)
    else
      total_stats
    end
  end

  defp format_date(datetime) do
    day = datetime.day
    month = DateHelpers.month_name(datetime.month)

    suffix = case day do
      1 -> "st"
      2 -> "nd"
      3 -> "rd"
      21 -> "st"
      22 -> "nd"
      23 -> "rd"
      31 -> "st"
      _ -> "th"
    end

    "#{day}#{suffix} of #{month}"
  end

  def count_items(items) do
    IO.puts("........count_items()")
    now = DateTime.utc_now()

    today = Enum.count(items, fn item ->
      item_datetime = parse_datetime(item.created_at)
      check = DateHelpers.is_today?(item_datetime, now)
      check
    end)

    this_month = Enum.count(items, fn item ->
      item_datetime = parse_datetime(item.created_at)
      DateHelpers.is_this_month?(item_datetime, now)
    end)

    this_quarter = Enum.count(items, fn item ->
      item_datetime = parse_datetime(item.created_at)
      DateHelpers.is_this_quarter?(item_datetime, now)
    end)

    this_year = Enum.count(items, fn item ->
      item_datetime = parse_datetime(item.created_at)
      DateHelpers.is_this_year?(item_datetime, now)
    end)

    %{
      today: today,
      this_month: this_month,
      this_quarter: this_quarter,
      this_year: this_year
    }
  end

  defp parse_datetime(datetime_str) do
    DateTime.from_iso8601(datetime_str)
    |> case do
         {:ok, dt, _offset} -> dt
         _ -> nil
       end
  end

end