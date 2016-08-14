defmodule ExPfds.LeftistHeapTest do
  use ExUnit.Case, async: true
  use ExCheck

  alias ExPfds.LeftistHeap
  alias ExPfds.BinaryTree

  property :put do
    for_all xs in list(int) do
      h = LeftistHeap.new(xs)
      LeftistHeap.sort(h) == Enum.sort(xs)
    end
  end

  property "put and right spine" do
    for_all xs in list(int) do
      h = LeftistHeap.new(xs)
      spine_length = BinaryTree.length_right_spine(h)
      max_spine_length = :math.log2(length(xs)+1)
      spine_length <= max_spine_length
    end
  end

  property :merge do
    for_all {xs, ys} in {list(int), list(int)} do
      xh = LeftistHeap.new(xs)
      yh = LeftistHeap.new(ys)
      h  = LeftistHeap.merge(xh, yh)
      LeftistHeap.sort(h) == Enum.sort(xs ++ ys)
    end
  end
end
