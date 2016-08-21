defmodule Purely.BST do
  @moduledoc """
  A set of functions for a purely functional implementation of a
  binary search tree (BST).

  Each node in the binary tree stores a key and a value in a tuple.
  Keys are compared with `<` and `>`.
  """

  @empty {}

  @type empty :: Purely.BinaryTree.empty
  @type t :: empty | Purely.BinaryTree.t

  @doc """
  Returns an empty BST.
  """
  @spec new() :: empty
  def new, do: @empty

  @doc """
  Returns a BST with all of the key-value pairs from `enumerable` added
  to it.
  """
  @spec new(Enum.t) :: t
  def new(enumerable) do
    Enum.reduce(enumerable, new, &flipped_put/2)
  end

  # TODO: new(enumerable, transform)

  defp build(kv), do: build(kv, @empty, @empty)
  defp build(kv, l, r), do: {kv, l, r}

  # TODO: equal?(bst1, bst2)

  @doc """
  Returns a list of the key-value pairs in the tree in order, sorted
  by key.
  """
  @spec inorder(t) :: [{term, term}]
  def inorder(bst), do: Enum.reverse(inorder(bst, []))
  defp inorder(@empty, acc), do: acc
  defp inorder({kv, l, r}, acc) do
    inorder(r, [kv | inorder(l, acc)])
  end

  @doc """
  Adds a key mapped to a value to the BST.
  """
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

  @doc """
  Returns the value mapped to the given key; if the key is not found,
  then `nil` is returned.
  """
  @spec get(t, term) :: term
  def get(bst, key), do: get(bst, key, nil)

  @doc """
  Returns the value mapped to the given key; if the key is not found,
  then the specified default value is returned.
  """
  @spec get(t, term, term) :: term
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

  # TODO: get_and_update(bst, key, fun)
  # TODO: get_and_update!(bst, key, fun)

  # TODO: get_lazy(bst, key, fun)

  # TODO: pop(bst, key, default \\ nil)
  # TODO: pop_lazy(bst, key, fun)

  # TODO: fetch(bst, key)
  # TODO: fetch!(bst, key)

  # TODO: update(map, key, initial, fun)
  # TODO: update!(map, key, fun)

  @doc """
  Returns true if the key is in the BST, false otherwise.
  """
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

  @doc """
  Returns the keys in the BST in order.
  """
  @spec keys(t) :: [term]
  def keys(bst) do
    inorder(bst) |> Enum.map(fn {k,_} -> k end)
  end

  # TODO: values(bst)

  # TODO: merge(bst1, bst2)
  # TODO: merge(bst1, bst2, callback)

  # TODO: split(bst, keys)

  # TODO: take(bst, keys)

  # TODO: to_list(bst)

  @doc """
  Deletes the given key (and its value) from the BST.
  """
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

  # TODO: drop(bst, keys)

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

# TODO: defimpl Enumerable, for: Purely.BST
