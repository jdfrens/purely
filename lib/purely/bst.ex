defmodule Purely.BST do
  @moduledoc """
  A set of functions for a purely functional implementation of a
  binary search tree (BST).

  Each node in the binary tree stores a key and a value in a tuple.
  Keys are compared with `<` and `>`.
  """

  @empty {}

  @type key :: any
  @type value :: any

  @type empty :: Purely.BinaryTree.empty
  @type bst :: empty | Purely.BinaryTree.t

  @doc """
  Returns an empty BST.
  """
  @spec new() :: empty
  def new, do: @empty

  @doc """
  Returns a BST with all of the key-value pairs from `enumerable` added
  to it.
  """
  @spec new(Enum.t) :: bst
  def new(enumerable) do
    Enum.reduce(enumerable, new, &flipped_put/2)
  end

  # TODO: new(enumerable, transform)
  @spec new(Enum.t, (term -> {key, value})) :: bst
  def new(enumerable, transform) do
    enumerable
    |> Enum.map(transform)
    |> new
  end

  defp build(kv), do: build(kv, @empty, @empty)
  defp build(kv, l, r), do: {kv, l, r}

  # TODO: equal?(bst1, bst2)
  @spec equal?(bst, bst) :: boolean
  def equal?(bst1, bst2) do
    inorder(bst1) === inorder(bst2)
  end

  @doc """
  Returns a list of the key-value pairs in the tree in order, sorted
  by key.
  """
  @spec inorder(bst) :: [{key, value}]
  def inorder(bst), do: Enum.reverse(inorder(bst, []))
  defp inorder(@empty, acc), do: acc
  defp inorder({kv, l, r}, acc) do
    inorder(r, [kv | inorder(l, acc)])
  end

  @doc """
  Adds a key mapped to a value to the BST.
  """
  @spec put(bst, key, value) :: bst
  def put(@empty, key, val), do: build({key, val})
  def put({{k, v}, l, r}, key, val) do
    cond do
      key < k ->
        build({k,v}, put(l, key, val), r)
      k < key ->
        build({k, v}, l, put(r, key, val))
      true ->
        build({k, val}, l, r)
    end
  end

  @spec put_new(bst, key, value) :: bst
  def put_new(bst, key, val) do
    cond do
      has_key?(bst, key) ->
        bst
      true ->
        put(bst, key, val)
    end
  end

  @doc """
  Returns the value mapped to the given key; if the key is not found,
  then `nil` is returned.
  """
  @spec put_new_lazy(bst, key, (() -> value)) :: bst
  def put_new_lazy(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        bst
      true ->
        put(bst, key, fun.())
    end
  end

  defp flipped_put({key, val}, bst), do: put(bst, key, val)

  @doc """
  Returns the value mapped to the given key; if the key is not found,
  then the specified default value is returned.
  """
  @spec get(bst, key) :: value
  @spec get(bst, key, value) :: value
  def get(bst, key, default \\ nil), do: get_bst(bst, key, default)

  defp get_bst(@empty, _, default), do: default
  defp get_bst({{k, v}, l, r}, key, default) do
    cond do
      key < k ->
        get_bst(l, key, default)
      k < key ->
        get_bst(r, key, default)
      true ->
        v
    end
  end

  @spec get_lazy(bst, key, (() -> value)) :: value
  def get_lazy(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        get(bst, key)
      true ->
        fun.()
    end
  end


  """
  @spec get_and_update(bst, key, (value -> {get, value} | :pop)) :: {get, bst} when get: term
  def get_and_update(bst, key, fun) do
    current = get(bst, key)
    case fun.(current) do
      {get, update} -> {get, put(bst, key, update)}
      :pop          -> {current, delete(bst, key)}
    end
  end


  """
  @spec get_and_update!(bst, key, (value -> {get, value})) :: {get, bst} | no_return when get: term
  def get_and_update!(bst, key, fun) do
    if has_key?(bst, key) do
      current = get(bst, key)
      case fun.(current) do
        {get, update} -> {get, put(bst, key, update)}
        :pop          -> {current, delete(bst, key)}
      end
    else
      :erlang.error({:badkey, key})
    end
  end

  @doc """
  Returns true if the key is in the BST, false otherwise.
  @spec update(bst, key, value, (value -> value)) :: bst
  def update(bst, key, initial, fun) do
    cond do
      has_key?(bst, key) ->
        value = get(bst, key)
        put(bst, key, fun.(value))
      true ->
        put(bst, key, initial)
    end
  end

  @spec update!(bst, key, (value -> value)) :: bst | no_return
  def update!(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        update(bst, key, :does_not_matter, fun)
      true ->
        :erlang.error({:badkey, key})
    end
  end

  """
  @spec has_key?(bst, key) :: boolean
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
  @spec keys(bst) :: [key]
  def keys(bst) do
    inorder(bst) |> Enum.map(fn {k,_} -> k end)
  end



  @spec values(bst) :: [value]
  def values(bst) do
    inorder(bst) |> Enum.map(fn {_,v} -> v end)
  end

  @spec merge(bst, bst) :: bst
  def merge(@empty, bst2), do: bst2
  def merge(bst1, @empty), do: bst1
  def merge(bst1, {{k,v}, bst2l, bst2r}) do
    bst1
    |> put(k, v)
    |> merge(bst2l)
    |> merge(bst2r)
  end

  @spec merge(bst, bst, (key, value, value -> value)) :: bst
  def merge(@empty, bst2, _), do: bst2
  def merge(bst1, @empty, _), do: bst1
  def merge(bst1, {{k,v}, bst2l, bst2r}, fun) do
    bst1
    |> merge_key(k, v, fun)
    |> merge(bst2l, fun)
    |> merge(bst2r, fun)
  end

  defp merge_key(bst, k, v, fun) do
    new_value =
      if has_key?(bst, k), do: fun.(k, get(bst, k), v), else: v
    put(bst, k, new_value)
  end

  @doc """
  Deletes the given key (and its value) from the BST.
  @spec split(bst, Enumerable.t) :: {bst, bst}
  def split(bst, keys) do
    Enum.reduce(keys, {new, bst}, fn key, {bst1, bst2} ->
      if has_key?(bst2, key) do
        {value, bst2} = pop(bst2, key)
        {put(bst1, key, value), bst2}
      else
        {bst1, bst2}
      end
    end)
  end

  @spec take(bst, Enumerable.t) :: bst
  def take(bst, keys) do
    {taken_bst, _} = split(bst, keys)
    taken_bst
  end

  @spec drop(bst, Enumerable.t) :: bst
  def drop(bst, keys) do
    {_, dropped_bst} = split(bst, keys)
    dropped_bst
  end

  @spec to_list(bst) :: [{key, value}]
  def to_list(bst) do
    inorder(bst)
  end

  @spec pop(bst, key, value) :: {value, bst}
  def pop(bst, key, default \\ nil) do
    {get(bst, key, default), delete(bst, key)}
  end

  @spec pop_lazy(bst, key, (() -> value)) :: {value, bst}
  def pop_lazy(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        pop(bst, key)
      true ->
        pop(bst, key, fun.())
    end
  end

  """
  @spec delete(bst, key) :: bst
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

# TODO: defimpl Enumerable, for: Purely.BST
