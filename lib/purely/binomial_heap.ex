defmodule Purely.BinomialHeap do
  @moduledoc """
  Implementation of a [binomial heap](https://en.wikipedia.org/wiki/Binomial_heap) using a binomial tree implemented in
  `Purely.BinomialTree`.
  """

  @empty []

  @type empty :: []
  @type t :: empty | [Purely.BinomialTree.t()]

  use Purely.Heap, empty_type: __MODULE__.empty(), type: __MODULE__.t()

  alias Purely.BinomialTree

  @spec put(t, term) :: t
  def put(bheap, v) do
    BinomialTree.put(bheap, BinomialTree.new(v))
  end

  @spec min(t) :: term
  def min(bheap) do
    bheap
    |> Enum.map(fn {_, v, _} -> v end)
    |> Enum.min()
  end

  @spec remove_min(t) :: t
  def remove_min(bheap) do
    {{_, _, ts1}, ts2} = remove_min_tree(bheap)
    merge(Enum.reverse(ts1), ts2)
  end

  defp remove_min_tree([t]), do: {t, []}

  defp remove_min_tree([{_, v, _} = t | ts]) do
    {{_, vv, _} = tt, tts} = remove_min_tree(ts)

    if v < vv do
      {t, ts}
    else
      {tt, [t | tts]}
    end
  end

  @spec merge(t, t) :: t
  def merge(ts, @empty), do: ts
  def merge(@empty, ts), do: ts

  def merge([tt1 | tts1] = ts1, [tt2 | tts2] = ts2) do
    cond do
      BinomialTree.rank(tt1) < BinomialTree.rank(tt2) ->
        [tt1 | merge(tts1, ts2)]

      BinomialTree.rank(tt2) < BinomialTree.rank(tt1) ->
        [tt2 | merge(ts1, tts2)]

      true ->
        BinomialTree.put(merge(tts1, tts2), BinomialTree.link(tt1, tt2))
    end
  end
end
