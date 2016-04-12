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
  def put({l, {k, v}, r}=bst, key, val) do
    cond do
      key < k ->
        build(put(l, key, val), {k,v}, r)
      k < key ->
        build(l, {k, v}, put(r, key, val))
      true ->
        bst
    end
  end
  # TODO: put_new(bst, key, val)
  # TODO: put_new_lazy(bst, key, fun)

  defp flipped_put({key, val}, bst), do: put(bst, key, val)

  def get(bst, key), do: get(bst, key, nil)
  def get(@empty, _, default), do: default
  def get({l, {k, v}, r}, key, default) do
    cond do
      key < k ->
        get(l, key, default)
      k < key ->
        get(r, key, default)
      true ->
        v
    end
  end
  # TODO: get_lazy(map, key, fun)

  def has_key?(@empty, _), do: false
  def has_key?({l, {k, _}, r}, key) do
    cond do
      key < k ->
        has_key?(l, key)
      k < key ->
        has_key?(r, key)
      true ->
        true
    end
  end

  def keys(bst) do
    inorder(bst) |> Enum.map(fn {k,_} -> k end)
  end

  def delete(@empty, _), do: @empty
  def delete({l, {k, v}, r}, key) do
    cond do
      key < k ->
        build(delete(l, key), {k,v}, r)
      k < key ->
        build(l, {k, v}, delete(r, key))
      true ->
        promote_leftmost(l, r)
    end
  end

  @doc """
  Purely a structural traversal to remove and return the leftmost
  key-value.  This leftmost key-value will replace a recently removed
  key.  `sibling` is the left sibling of the deleted node and will be
  left sibling of new node.
  """
  defp promote_leftmost(sibling, @empty), do: sibling
  defp promote_leftmost(sibling, {@empty, kv, r}) do
    build(sibling, kv, r)
  end
  defp promote_leftmost(sibling, {l, kv, r}) do
    {sibling, newkv, new_l} = promote_leftmost(sibling, l)
    build(sibling, newkv, build(new_l, kv, r))
  end
end
