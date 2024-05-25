defmodule BrewDash.DatabaseBrewProvider do
  use HomeDash.Provider
  alias BrewDash.Brews

  @displayable_sessions 8

  @impl true
  def handle_cards(:init, opts) do
    BrewDash.Sync.subscribe(:brew_sessions)

    cards =
      [:serving, :conditioning]
      |> fetch_brew_sessions(opts)
      |> Enum.with_index()
      |> Enum.map(&session_to_card/1)

    {:ok, cards}
  end

  def handle_cards(:brew_sessions_updated, opts) do
    cards =
      [:serving, :conditioning]
      |> fetch_brew_sessions(opts)
      |> Enum.with_index()
      |> Enum.map(&session_to_card/1)

    {:ok, cards}
  end

  defp fetch_brew_sessions(statuses, opts) do
    num_displayable = Keyword.get(opts, :num_displayable, @displayable_sessions)

    statuses
    |> Brews.Brew.with_statuses()
    |> Enum.sort(&Brews.Display.sort_tap_number/2)
    |> append_new_sessions()
    |> Enum.sort(&Brews.Display.sort_status/2)
    |> Enum.take(num_displayable)
  end

  defp append_new_sessions(sessions) when length(sessions) < @displayable_sessions do
    sessions = Brews.Brew.brewing() ++ sessions
    List.flatten([Brews.Brew.fermenting(@displayable_sessions - length(sessions)) | sessions])
  end

  defp append_new_sessions(sessions), do: sessions

  defp session_to_card({brew, index}) do
    %HomeDash.Card{
      namespace: __MODULE__,
      card_component: HomeDashWeb.Cards.BrewDashTaps,
      id: to_string(brew.id),
      order: index,
      data: Brews.to_map(brew, true)
    }
  end
end
