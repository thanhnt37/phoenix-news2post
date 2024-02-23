defmodule News2PostWeb.ErrorJSONTest do
  use News2PostWeb.ConnCase, async: true

  test "renders 404" do
    assert News2PostWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert News2PostWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
