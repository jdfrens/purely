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

  @spec new() :: empty_bst
  def new, do: @empty
  def new(enumerable) do
    Enum.reduce(enumerable, new, &flipped_put/2)
  end
  # TODO: new(enumerable, transform)

  @spec build(key_value) :: nonempty_bst
  defp build(kv), do: build(@empty, kv, @empty)
  @spec build(bst, key_value, bst) :: nonempty_bst
  defp build(l, kv, r), do: {l, kv, r}

  @spec inorder(bst()) :: list(any())
  def inorder(bst), do: inorder(bst, []) |> Enum.reverse
  defp inorder(@empty, acc), do: acc
  defp inorder({l, kv, r}, acc) do
    inorder(r, [kv | inorder(l, acc)])
  end

  @spec put(bst(), any(), any()) :: bst()
  def put(@empty, key, val), do: build({key, val})
  def put({l, {k, v}, r}, key, val) when key < k do
    build(put(l, key, val), {k,v}, r)
  end
  def put({l, {k,v}, r}, key, val) when k < key do
    build(l, {k, v}, put(r, key, val))
  end
  def put(bst, _key, _val), do: bst
  # TODO: put_new(bst, key, val)
  # TODO: put_new_lazy(bst, key, fun)

  defp flipped_put({key, val}, bst), do: put(bst, key, val)
end
