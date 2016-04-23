defmodule ExPfds.BinomialHeap do

  @empty []
  use ExPfds.Heap

  alias ExPfds.BinomialTree

  def put(bheap, v) do
    BinomialTree.put(bheap, BinomialTree.new(v))
  end

  def min(bheap) do
    bheap
    |> Enum.map(fn {_,v,_} -> v end)
    |> Enum.min
  end

  def remove_min(bheap) do
    {{_, _, ts1}, ts2} = remove_min_tree(bheap)
    merge(Enum.reverse(ts1), ts2)
  end

  defp remove_min_tree([t]), do: {t, []}
  defp remove_min_tree([{_,v,_}=t | ts]) do
    {{_,vv,_}=tt, tts} = remove_min_tree(ts)
    if v < vv do
      {t, ts}
    else
      {tt, [t | tts]}
    end
  end

  def merge(ts, @empty), do: ts
  def merge(@empty, ts), do: ts
  def merge([tt1 | tts1]=ts1, [tt2 | tts2]=ts2) do
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
