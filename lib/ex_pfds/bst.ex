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

  def get(bst, key), do: get(bst, key, nil)
  def get(@empty, _, default), do: default
  def get({l, {k, _}, _}, key, default) when key < k do
    get(l, key, default)
  end
  def get({_, {k, _}, r}, key, default) when k < key do
    get(r, key, default)
  end
  def get({_, {_, v}, _}, _, _), do: v
  # TODO: get_lazy(map, key, fun)

  def has_key?(@empty, _), do: false
  def has_key?({l, {k, _}, _}, key) when key < k do
    has_key?(l, key)
  end
  def has_key?({_, {k, _}, r}, key) when k < key do
    has_key?(r, key)
  end
  def has_key?(_, _), do: true

  def keys(bst) do
    inorder(bst) |> Enum.map(fn {k,_} -> k end)
  end

  def delete(@empty, _), do: @empty
  def delete({l, {k, v}, r}, key) when key < k do
    build(delete(l, key), {k,v}, r)
  end
  def delete({l, {k,v}, r}, key) when k < key do
    build(l, {k, v}, delete(r, key))
  end
  def delete({l, {_,_}, r}, _) do
    case promote_leftmost(r) do
      {:nothing}          -> l
      {:ok, newkv, new_r} -> build(l, newkv, new_r)
    end
  end

  # Purely a structural traversal to remove and return the leftmost
  # key-value.  This leftmost key-value will replace a recently
  # removed key.
  defp promote_leftmost(@empty), do: {:nothing}
  defp promote_leftmost({@empty, kv, r}) do
    {:ok, kv, r}
  end
  defp promote_leftmost({l, kv, r}) do
    {:ok, newkv, new_l} = promote_leftmost(l)
    {:ok, newkv, build(new_l, kv, r)}
  end
end
