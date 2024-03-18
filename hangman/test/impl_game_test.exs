defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
  end

  test "state doesn't change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "a duplicate letter is reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "we record leters used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")
    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we recognize a lette in the word" do
    game = Game.new_game("wombat")
    {game, _tally} = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    {game, _tally} = Game.make_move(game, "t")
    assert game.game_state == :good_guess
  end

  test "we recognize a lette not in the word" do
    game = Game.new_game("wombat")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    {game, _tally} = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state == :bad_guess
  end

  test "we recognize a win" do
    game = Game.new_game("wombat")
    {game, _tally} = Game.make_move(game, "w")
    {game, _tally} = Game.make_move(game, "o")
    {game, _tally} = Game.make_move(game, "m")
    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "a")
    {game, _tally} = Game.make_move(game, "t")
    assert game.game_state == :won
  end

  test "can handle a winning game" do
    [
      # guess | state | turns | letters | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "x", "l"]],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], ["a", "e", "x", "l", "o"]],
      ["y", :bad_guess, 4, ["_", "e", "l", "l", "o"], ["a", "e", "x", "l", "o", "y"]],
      ["h", :won, 4, ["h", "e", "l", "l", "o"], ["a", "e", "x", "l", "o", "y", "h"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    [
      # guess | state | turns | letters | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["e", :good_guess, 3, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e"]],
      ["f", :bad_guess, 2, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f"]],
      ["g", :bad_guess, 1, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g"]],
      ["h", :good_guess, 1, ["h", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g", "h"]],
      ["i", :lost, 0, ["h", "e", "l", "l", "o"], ["a", "b", "c", "d", "e", "f", "g", "h", "i"]]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(sequence) do
    game = Game.new_game("hello")
    Enum.reduce(sequence, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert MapSet.equal?(MapSet.new(tally.used), MapSet.new(used))
    game
  end
end
