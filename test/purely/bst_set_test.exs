defmodule Purely.BSTSetTest do
  use ExUnit.Case, async: true

  alias Purely.BSTSet

  test "to_list of empty set" do
    assert BSTSet.to_list(BSTSet.new) == []
  end

  test "to_list of interesting set" do
    set = BSTSet.new([1, 2, 4, 3, 9, 7])
    assert BSTSet.to_list(set) == [1, 2, 3, 4, 7, 9]
  end

  test "put several values" do
    set = BSTSet.new |> BSTSet.put(3) |> BSTSet.put(6) |> BSTSet.put(2)
    assert BSTSet.to_list(set) == [2, 3, 6]
  end

  test "put duplicates" do
    set = BSTSet.new |> BSTSet.put(3) |> BSTSet.put(3) |> BSTSet.put(3)
    assert BSTSet.to_list(set) == [3]
  end

  describe "ExCheck" do
    use ExCheck

    property :put do
      for_all xs in list(int(1, 5000)) do
        set = BSTSet.new(xs)
        BSTSet.to_list(set) == Enum.uniq(Enum.sort(xs))
      end
    end
  end

  describe "Quixir" do
    use Quixir

    test "put and sort" do
      ptest xs: list(of: int(min: 1, max: 5000)) do
        set = BSTSet.new(xs)
        assert BSTSet.to_list(set) == Enum.uniq(Enum.sort(xs))
      end
    end
  end

  test "not a member" do
    set = BSTSet.new([1, 2, 4, 3, 9, 7])
    refute BSTSet.member?(set, 99)
  end

  test "member" do
    set = BSTSet.new([1, 2, 4, 3, 9, 7])
    assert BSTSet.member?(set, 4)
  end
end
