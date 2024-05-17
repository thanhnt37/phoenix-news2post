defmodule News2Post.DateHelpers do
  @months ~w(January February March April May June July August September October November December)

  def month_name(month) do
    Enum.at(@months, month - 1)
  end

  def is_today?(item_datetime, now) do
    item_datetime.year == now.year and
    item_datetime.month == now.month and
    item_datetime.day == now.day
  end

  def is_this_month?(item_datetime, now) do
    item_datetime.year == now.year and
    item_datetime.month == now.month
  end

  def is_this_quarter?(item_datetime, now) do
    item_datetime.year == now.year and
    div(item_datetime.month - 1, 3) == div(now.month - 1, 3)
  end

  def is_this_year?(item_datetime, now) do
    item_datetime.year == now.year
  end
end
