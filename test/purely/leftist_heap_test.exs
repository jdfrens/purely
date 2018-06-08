defmodule Purely.LeftistHeapTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Purely.LeftistHeap
  alias Purely.BinaryTree

  property "new, put, and sort" do
    check all xs <- list_of(integer()) do
      h = LeftistHeap.new(xs)
      assert LeftistHeap.sort(h) == Enum.sort(xs)
    end
  end

  property "length of right spine" do
    check all xs <- list_of(integer()) do
      h = LeftistHeap.new(xs)
      spine_length = BinaryTree.length_right_spine(h)
      max_spine_length = :math.log2(length(xs) + 1)
      assert spine_length <= max_spine_length
    end
  end

  property "merge preserves sort" do
    check all xs <- list_of(integer()),
              ys <- list_of(integer()) do
      xh = LeftistHeap.new(xs)
      yh = LeftistHeap.new(ys)
      h = LeftistHeap.merge(xh, yh)
      assert LeftistHeap.sort(h) == Enum.sort(xs ++ ys)
    end
  end
end
