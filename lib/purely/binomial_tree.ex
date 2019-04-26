defmodule Purely.BinomialTree do
  @moduledoc """
  Implementation of a [binomial tree](https://en.wikipedia.org/wiki/Binomial_heap) which is used to implement a heap
  with `Purely.BinomialHeap`.
  """

  @type singleton :: {0, term, []}
  @type t :: singleton | {integer, term, [t]}

  @spec new(term) :: singleton
  def new(value) do
    {0, value, []}
  end

  @spec link(t, t) :: t
  def link({r, v1, c1} = t1, {_, v2, c2} = t2) do
    if v1 <= v2 do
      {r + 1, v1, [t2 | c1]}
    else
      {r + 1, v2, [t1 | c2]}
    end
  end

  @spec put([t], t) :: [t]
  def put([], t), do: [t]

  def put([first | rest] = all, t) do
    if rank(t) < rank(first) do
      [t | all]
    else
      put(rest, link(t, first))
    end
  end

  @spec rank(t) :: integer
  def rank({r, _, _}), do: r
end
