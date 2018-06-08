defmodule Purely.BinomialHeapTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Purely.BinomialHeap

  property "a binomial heap is a list" do
    check all xs <- list_of(integer()) do
      assert is_list(BinomialHeap.new(xs))
    end
  end

  property "min" do
    check all xs <- list_of(integer(), min_length: 1) do
      h = BinomialHeap.new(xs)
      assert BinomialHeap.min(h) == Enum.min(xs)
    end
  end

  property "put and sort" do
    check all xs <- list_of(integer()) do
      h = BinomialHeap.new(xs)
      assert BinomialHeap.sort(h) == Enum.sort(xs)
    end
  end
end
