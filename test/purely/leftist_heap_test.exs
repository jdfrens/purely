defmodule Purely.LeftistHeapTest do
  use ExUnit.Case, async: true
  use Quixir

  alias Purely.LeftistHeap
  alias Purely.BinaryTree

  test "new, put, and sort" do
    ptest xs: list(of: int()) do
      h = LeftistHeap.new(xs)
      assert LeftistHeap.sort(h) == Enum.sort(xs)
    end
  end

  test "length of right spine" do
    ptest xs: list(of: int()) do
      h = LeftistHeap.new(xs)
      spine_length = BinaryTree.length_right_spine(h)
      max_spine_length = :math.log2(length(xs)+1)
      assert spine_length <= max_spine_length
    end
  end

  test "merge preserves sort" do
    ptest xs: list(of: int()), ys: list(of: int()) do
      xh = LeftistHeap.new(xs)
      yh = LeftistHeap.new(ys)
      h  = LeftistHeap.merge(xh, yh)
      assert LeftistHeap.sort(h) == Enum.sort(xs ++ ys)
    end
  end
end
