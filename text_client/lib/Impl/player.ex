defmodule TextClient.Impl.Player do
  @type game :: Hangman.game()
  @type tally :: Hangman.tally()
  @type state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    IO.puts(game.letters |> Enum.join(" "))
    interact({game, tally})
  end

  @spec interact(state) :: :ok
  def interact({_game, tally = %{game_state: :won}}) do
    IO.puts("Congratulations. You won!\n")
    IO.puts("The word was indeed: #{tally.letters |> Enum.join()}")
  end

  def interact({_game, tally = %{game_state: :lost}}) do
    IO.puts("Sorry. You lost ... the word was #{tally.letters |> Enum.join()}")
  end

  def interact({game, tally}) do
    IO.puts(feedback_for(tally))
    IO.puts(current_word(tally))

    Hangman.make_move(game, get_guess())
    |> interact()
  end

  def feedback_for(tally = %{game_state: :initializing}) do
    "Welcome!. I am thinking of a  #{tally.letters |> length} letter word."
  end

  def feedback_for(_tally = %{game_state: :good_guess}), do: "Good guess!\n"

  def feedback_for(_tally = %{game_state: :bad_guess}),
    do: "Sorry, that letter is not in the word.\n"

  def feedback_for(_tally = %{game_state: :already_used}), do: "You already used that letter.\n"

  def current_word(tally) do
    [
      "Word so far: ",
      tally.letters |> Enum.join(" "),
      "   Turns left: ",
      tally.turns_left |> to_string,
      "   Used: ",
      tally.used |> Enum.join(",")
    ]
  end

  def get_guess() do
    IO.gets("Next letter: ") |> String.trim() |> String.downcase()
  end
end
