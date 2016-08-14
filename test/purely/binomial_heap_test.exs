defmodule Purely.BinomialHeapTest do
  use ExUnit.Case, async: true
  use ExCheck

  alias Purely.BinomialHeap

  property :new do
    for_all xs in list(int) do
      is_list(BinomialHeap.new(xs))
    end
  end

  property :min do
    for_all xs in non_empty(list(int)) do
      h = BinomialHeap.new(xs)
      BinomialHeap.min(h) == Enum.min(xs)
    end
  end

  property :put do
    for_all xs in list(int) do
      h = BinomialHeap.new(xs)
      BinomialHeap.sort(h) == Enum.sort(xs)
    end
  end
end
