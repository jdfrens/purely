defmodule ExPfds.BST do
  @moduledoc """
  Implementation of a purely functional binary search tree.
  """

  @typedoc """
  An empty tuple for an empty tree; a three-tuple (left, value, right)
  for a general node.
  """
  @type key_value :: {any, any}
  @type empty_bst :: {}
  @type nonempty_bst :: {bst, key_value, bst}
  @type bst :: empty_bst | nonempty_bst

  @empty {}

  @spec empty() :: empty_bst
  def empty, do: @empty

  @spec build(key_value) :: nonempty_bst
  def build(kv), do: build(@empty, kv, @empty)
  @spec build(bst, key_value, bst) :: nonempty_bst
  def build(l, kv, r), do: {l, kv, r}

  @spec inorder(bst()) :: list(any())
  def inorder(bst), do: inorder(bst, []) |> Enum.reverse
  defp inorder(@empty, acc), do: acc
  defp inorder({l, kv, r}, acc) do
    inorder(r, [kv | inorder(l, acc)])
  end

  @spec insert(bst(), key_value()) :: bst()
  def insert(@empty, new_kv), do: build(new_kv)
  def insert({l, {k,v}, r}, {nk,nv}) when nk < k do
    build(insert(l, {nk,nv}), {k,v}, r)
  end
  def insert({l, {k,v}, r}, {nk,nv}) when k < nk do
    build(l, {k,v}, insert(r, {nk,nv}))
  end
  def insert(bst, {_,_}), do: bst
end
