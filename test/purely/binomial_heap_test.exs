defmodule Purely.BinomialHeapTest do
  use ExUnit.Case, async: true

  alias Purely.BinomialHeap

  describe "Quixir" do
    use Quixir

    test "a binomail heap is a list" do
      ptest xs: list(of: int()) do
        assert is_list(BinomialHeap.new(xs))
      end
    end

    test "min" do
      ptest xs: list(of: int(), min: 1) do
        h = BinomialHeap.new(xs)
        assert BinomialHeap.min(h) == Enum.min(xs)
      end
    end

    test "put and sort" do
      ptest xs: list(of: int()) do
        h = BinomialHeap.new(xs)
        assert BinomialHeap.sort(h) == Enum.sort(xs)
      end
    end
  end
end
