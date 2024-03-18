defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary

  test "word_list/0 returns a list of words" do
    assert length(Dictionary.start()) > 0
  end
end
