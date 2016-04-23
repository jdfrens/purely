defmodule ExPfds.BinomialTree do
  def new(value) do
    {0, value, []}
  end

  def link({r, v1, c1}=t1, {_, v2, c2}=t2) do
    if v1 <= v2 do
      {r+1, v1, [t2 | c1]}
    else
      {r+1, v2, [t1 | c2]}
    end
  end

  def put([], t), do: [t]
  def put([first | rest]=all, t) do
    if rank(t) < rank(first) do
      [t | all]
    else
      put(rest, link(t, first))
    end
  end

  def rank({r, _, _}), do: r
end
