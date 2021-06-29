defmodule BrewDash.Brews.Brew do
  require Ecto.Query
  alias BrewDash.Repo
  alias BrewDash.Schema

  def serving, do: all_with_statuses([:serving])
  def conditioning, do: all_with_statuses([:conditioning])

  @spec all_with_statuses(list(atom())) :: [Ecto.Schema.t()]
  def all_with_statuses(statuses),
    do: Schema.Brew |> where_status(statuses) |> load_recipe() |> Repo.all()

  def where_status(query, statuses) when is_list(statuses),
    do: Ecto.Query.where(query, [s], s.status in ^statuses)

  def load_recipe(query), do: Ecto.Query.preload(query, [:recipe])

  def upsert!(changeset), do: Repo.insert!(changeset, on_conflict: {:replace_all_except, [:id]})
end
