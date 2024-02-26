defmodule News2PostWeb.NewsHTML do
  use News2PostWeb, :html

  embed_templates "news_html/*"

  @doc """
  Renders a news form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def news_form(assigns)
end
