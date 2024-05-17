defmodule News2Post.DateHelpers do
  @months ~w(January February March April May June July August September October November December)

  def month_name(month) do
    Enum.at(@months, month - 1)
  end
end
