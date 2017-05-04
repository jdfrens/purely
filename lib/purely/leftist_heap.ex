defmodule Purely.LeftistHeap do
  alias Purely.BinaryTree

  def new, do: BinaryTree.empty
  def new(enumerable) do
    Enum.reduce(enumerable, BinaryTree.empty, &(put(&2,&1)))
  end

  def empty?(h), do: h.empty

  def sort(h), do: sort(h, [])
  def sort(%BinaryTree{empty: true}, mins) do
    Enum.reverse(mins)
  end
  def sort(h, mins) do
    sort(remove_min(h), [min(h) | mins])
  end

  def put(h, value) do
    merge(build(value), h)
  end

  def min(%BinaryTree{empty: true}), do: nil
  def min(%BinaryTree{payload: {_, value}}), do: value

  def remove_min(%BinaryTree{empty: true}), do: nil
  def remove_min(%BinaryTree{left: l, right: r}), do: merge(l, r)

  def merge(h1, %BinaryTree{empty: true}), do: h1
  def merge(%BinaryTree{empty: true}, h2), do: h2
  def merge(
    %BinaryTree{payload: {_, v1}, left: l1, right: r1} = h1,
    %BinaryTree{payload: {_, v2}, left: l2, right: r2} = h2
  ) do
    cond do
      v1 < v2 ->
        build(v1, l1, merge(r1, h2))
      true ->
        build(v2, l2, merge(h1, r2))
    end
  end

  defp rank(%BinaryTree{empty: true}), do: 0
  defp rank(%BinaryTree{payload: {rank, _}}), do: rank

  defp build(v), do: build(v, BinaryTree.empty, BinaryTree.empty)
  defp build(v, l, r) do
    cond do
      rank(l) >= rank(r) ->
        %BinaryTree{payload: {rank(r) + 1, v}, left: l, right: r}
      true ->
        %BinaryTree{payload: {rank(l) + 1, v}, left: r, right: l}
    end
  end
end
