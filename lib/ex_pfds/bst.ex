defmodule ExPfds.BST do
  @moduledoc """
  Implementation of a purely functional binary search tree.
  """

  @empty {}

  @type empty :: ExPfds.BinaryTree.empty
  @type t :: empty | ExPfds.BinaryTree.t

  @spec new() :: empty
  def new, do: @empty
  @spec new(Enum.t) :: t
  def new(enumerable) do
    Enum.reduce(enumerable, new, &flipped_put/2)
  end
  # TODO: new(enumerable, transform)

  defp build(kv), do: build(kv, @empty, @empty)
  defp build(kv, l, r), do: {kv, l, r}

  @spec inorder(t) :: [term]
  def inorder(bst), do: Enum.reverse(inorder(bst, []))
  defp inorder(@empty, acc), do: acc
  defp inorder({kv, l, r}, acc) do
    inorder(r, [kv | inorder(l, acc)])
  end

  @spec put(t, term, term) :: t
  def put(@empty, key, val), do: build({key, val})
  def put({{k, v}, l, r}=bst, key, val) do
    cond do
      key < k ->
        build({k,v}, put(l, key, val), r)
      k < key ->
        build({k, v}, l, put(r, key, val))
      true ->
        bst
    end
  end
  # TODO: put_new(bst, key, val)
  # TODO: put_new_lazy(bst, key, fun)

  defp flipped_put({key, val}, bst), do: put(bst, key, val)

  @spec get(t, term) :: term
  def get(bst, key), do: get(bst, key, nil)
  def get(@empty, _, default), do: default
  def get({{k, v}, l, r}, key, default) do
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

  @spec has_key?(t, term) :: boolean
  def has_key?(@empty, _), do: false
  def has_key?({{k, _}, l, r}, key) do
    cond do
      key < k ->
        has_key?(l, key)
      k < key ->
        has_key?(r, key)
      true ->
        true
    end
  end

  @spec keys(t) :: [term]
  def keys(bst) do
    inorder(bst) |> Enum.map(fn {k,_} -> k end)
  end

  @spec delete(t, term) :: t
  def delete(@empty, _), do: @empty
  def delete({{k, v}, l, r}, key) do
    cond do
      key < k ->
        build({k,v}, delete(l, key), r)
      k < key ->
        build({k,v}, l, delete(r, key))
      true ->
        promote_leftmost(l, r)
    end
  end

  @docp """
  Purely a structural traversal to remove and return the leftmost
  key-value.  This leftmost key-value will replace a recently removed
  key.  `sibling` is the left sibling of the deleted node and will be
  left sibling of new node.
  """
  defp promote_leftmost(sibling, @empty), do: sibling
  defp promote_leftmost(sibling, {kv, @empty, r}) do
    build(kv, sibling, r)
  end
  defp promote_leftmost(sibling, {kv, l, r}) do
    {newkv, sibling, new_l} = promote_leftmost(sibling, l)
    build(newkv, sibling, build(kv, new_l, r))
  end
end
