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

  @type empty :: Purely.BinaryTree.empty()
  @type bst :: empty | Purely.BinaryTree.t()

  @doc """
  Returns an empty BST.

  ## Examples

      iex> Purely.BST.new
      {}

  """
  @spec new() :: empty
  def new, do: @empty

  @doc """
  Creates a BST from an `enumerable`.

  Duplicated keys are removed; the latest one prevails.

  ## Examples

      iex> Purely.BST.new([{:b, 1}, {:a, 2}]) |> Purely.BST.inorder
      [a: 2, b: 1]
      iex> Purely.BST.new([a: 1, a: 2, a: 3]) |> Purely.BST.inorder
      [a: 3]
      iex> Purely.BST.new(a: 1, b: 2) |> Purely.BST.inorder
      [a: 1, b: 2]

  """
  @spec new(Enum.t()) :: bst
  def new(enumerable) do
    Enum.reduce(enumerable, new(), &flipped_put/2)
  end

  @doc """
  Creates a BST from an `enumerable` via the transformation function.

  Duplicated keys are removed; the latest one prevails.

  ## Examples

      iex> Purely.BST.new([:a, :b], fn x -> {x, x} end) |> Purely.BST.inorder
      [a: :a, b: :b]

  """
  @spec new(Enum.t(), (term -> {key, value})) :: bst
  def new(enumerable, transform) do
    enumerable
    |> Enum.map(transform)
    |> new
  end

  defp build(kv), do: build(kv, @empty, @empty)
  defp build(kv, l, r), do: {kv, l, r}

  @doc """
  Checks if two BSTs are equal.

  Two BSTs are considered to be equal if they contain the same keys
  and those keys map to the same values.

  ## Examples

      iex> bst1 = Purely.BST.new(a: 1, b: 2)
      iex> bst2 = Purely.BST.new(b: 2, a: 1)
      iex> bst3 = Purely.BST.new(a: 11, b: 22)
      iex> Purely.BST.equal?(bst1, bst2)
      true
      iex> Purely.BST.equal?(bst1, bst3)
      false

  """
  @spec equal?(bst, bst) :: boolean
  def equal?(bst1, bst2) do
    inorder(bst1) === inorder(bst2)
  end

  @doc """
  Returns a list of the key-value pairs in the tree in order, sorted
  by key.

  ## Examples

      iex> bst = Purely.BST.new(b: 9, e: 2, d: 1, a: 22, c: 3)
      iex> Purely.BST.inorder(bst)
      [a: 22, b: 9, c: 3, d: 1, e: 2]

  """
  @spec inorder(bst) :: [{key, value}]
  def inorder(bst), do: Enum.reverse(inorder(bst, []))
  defp inorder(@empty, acc), do: acc

  defp inorder({kv, l, r}, acc) do
    inorder(r, [kv | inorder(l, acc)])
  end

  @doc """
  Puts the given `value` under `key`.

  If the `key` already exists, its value is replaced with `value`.

  ## Examples

      iex> bst = Purely.BST.new
      iex> bst = Purely.BST.put(bst, :a, 1)
      iex> bst |> Purely.BST.inorder
      [a: 1]
      iex> bst = Purely.BST.put(bst, :b, 2)
      iex> bst |> Purely.BST.inorder
      [a: 1, b: 2]
      iex> bst = Purely.BST.put(bst, :a, 3)
      iex> bst |> Purely.BST.inorder
      [a: 3, b: 2]

  """
  @spec put(bst, key, value) :: bst
  def put(@empty, key, val), do: build({key, val})

  def put({{k, v}, l, r}, key, val) do
    cond do
      key < k ->
        build({k, v}, put(l, key, val), r)

      k < key ->
        build({k, v}, l, put(r, key, val))

      true ->
        build({k, val}, l, r)
    end
  end

  @doc """
  Puts the given `value` under `key` unless `key` is already in
  the BST.

  If the `key` already exists, the BST is returned unchanged.

  ## Examples

      iex> bst = Purely.BST.new
      iex> bst = Purely.BST.put_new(bst, :a, 1)
      iex> bst |> Purely.BST.inorder
      [a: 1]
      iex> bst = Purely.BST.put_new(bst, :b, 2)
      iex> bst |> Purely.BST.inorder
      [a: 1, b: 2]
      iex> bst = Purely.BST.put_new(bst, :a, 3)
      iex> bst |> Purely.BST.inorder
      [a: 1, b: 2]

  """
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
  Evaluates `fun` and puts the result under `key` in BST unless
  `key` is already present.

  This is useful if the value is very expensive to calculate or
  generally difficult to setup and teardown again.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> fun = fn ->
      ...>   # some expensive operation here
      ...>   3
      ...> end
      iex> Purely.BST.put_new_lazy(bst, :a, fun) |> Purely.BST.inorder
      [a: 1]
      iex> Purely.BST.put_new_lazy(bst, :b, fun) |> Purely.BST.inorder
      [a: 1, b: 3]

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
  Gets the value for a specific `key`.

  If `key` does not exist, return the default value (`nil` if no
  default value).

  ## Examples

      iex> Purely.BST.get(Purely.BST.new, :a)
      nil
      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.get(bst, :a)
      1
      iex> Purely.BST.get(bst, :b)
      nil
      iex> Purely.BST.get(bst, :b, 3)
      3

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

  @doc """
  Gets the value for a specific `key`.

  If `key` does not exist, lazily evaluates `fun` and returns its result.
  This is useful if the default value is very expensive to calculate or
  generally difficult to setup and teardown again.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> fun = fn ->
      ...>   # some expensive operation here
      ...>   13
      ...> end
      iex> Purely.BST.get_lazy(bst, :a, fun)
      1
      iex> Purely.BST.get_lazy(bst, :b, fun)
      13

  """
  @spec get_lazy(bst, key, (() -> value)) :: value
  def get_lazy(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        get(bst, key)

      true ->
        fun.()
    end
  end

  @doc """
  Gets the value from `key` and updates it, all in one pass.

  This `fun` argument receives the value of `key` (or `nil` if `key`
  is not present) and must return a two-element tuple: the "get" value
  (the retrieved value, which can be operated on before being returned)
  and the new value to be stored under `key`. The `fun` may also
  return `:pop`, implying the current value shall be removed
  from `map` and returned.

  The returned value is a tuple with the "get" value returned by
  `fun` and a new map with the updated value under `key`.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.get_and_update(bst, :a, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      {1, {{:a, "new value!"}, {}, {}}}
      iex> Purely.BST.get_and_update(bst, :b, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      {nil, {{:a, 1}, {}, {{:b, "new value!"}, {}, {}}}}
      iex> Purely.BST.get_and_update(bst, :a, fn _ -> :pop end)
      {1, {}}
      iex> Purely.BST.get_and_update(bst, :b, fn _ -> :pop end)
      {nil, {{:a, 1}, {}, {}}}

  """
  @spec get_and_update(bst, key, (value -> {get, value} | :pop)) :: {get, bst} when get: term
  def get_and_update(bst, key, fun) do
    current = get(bst, key)

    case fun.(current) do
      {get, update} -> {get, put(bst, key, update)}
      :pop -> {current, delete(bst, key)}
    end
  end

  @doc """
  Gets the value from `key` and updates it. Raises if there is no `key`.

  This `fun` argument receives the value of `key` and must return a
  two-element tuple: the "get" value (the retrieved value, which can be
  operated on before being returned) and the new value to be stored under
  `key`.

  The returned value is a tuple with the "get" value returned by `fun` and a
  new map with the updated value under `key`.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.get_and_update!(bst, :a, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      {1, {{:a, "new value!"}, {}, {}}}
      iex> Purely.BST.get_and_update!(bst, :b, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      ** (KeyError) key :b not found
      iex> Purely.BST.get_and_update!(bst, :a, fn _ -> :pop end)
      {1, {}}

  """
  @spec get_and_update!(bst, key, (value -> {get, value})) :: {get, bst} | no_return
        when get: term
  def get_and_update!(bst, key, fun) do
    if has_key?(bst, key) do
      current = get(bst, key)

      case fun.(current) do
        {get, update} -> {get, put(bst, key, update)}
        :pop -> {current, delete(bst, key)}
      end
    else
      :erlang.error({:badkey, key})
    end
  end

  @doc """
  Updates the `key` in `map` with the given function.

  If the `key` does not exist, inserts the given `initial` value.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.update(bst, :a, 13, &(&1 * 2)) |> Purely.BST.inorder
      [a: 2]
      iex> Purely.BST.update(bst, :b, 11, &(&1 * 2)) |> Purely.BST.inorder
      [a: 1, b: 11]

  """
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

  @doc """
  Updates the `key` with the given function.

  If the `key` does not exist, raises `KeyError`.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.update!(bst, :a, &(&1 * 2)) |> Purely.BST.inorder
      [a: 2]
      iex> Purely.BST.update!(bst, :b, &(&1 * 2))
      ** (KeyError) key :b not found

  """
  @spec update!(bst, key, (value -> value)) :: bst | no_return
  def update!(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        update(bst, key, :does_not_matter, fun)

      true ->
        :erlang.error({:badkey, key})
    end
  end

  @doc """
  Returns whether a given `key` exists in the given `map`.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.has_key?(bst, :a)
      true
      iex> Purely.BST.has_key?(bst, :b)
      false

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
  Returns all keys from `bst`, in order.

  ## Examples

      iex> Purely.BST.keys(Purely.BST.new(a: 1, b: 2))
      [:a, :b]

  """
  @spec keys(bst) :: [key]
  def keys(bst) do
    bst |> inorder() |> Enum.map(fn {k, _} -> k end)
  end

  @doc """
  Returns all values from `bst`.  Values are order by their respective
  *keys*.

  ## Examples

      iex> Purely.BST.values(Purely.BST.new(a: 100, b: 20))
      [100, 20]

  """
  @spec values(bst) :: [value]
  def values(bst) do
    bst |> inorder() |> Enum.map(fn {_, v} -> v end)
  end

  @doc """
  Merges two BSTs into one.

  All keys in `bst2` will be added to `bst1`, overriding any existing one.

  ## Examples

      iex> Purely.BST.merge(
      ...>   Purely.BST.new(a: 1, b: 2),
      ...>   Purely.BST.new(a: 3, d: 4)
      ...> ) |> Purely.BST.inorder
      [a: 3, b: 2, d: 4]

  """
  @spec merge(bst, bst) :: bst
  def merge(@empty, bst2), do: bst2
  def merge(bst1, @empty), do: bst1

  def merge(bst1, {{k, v}, bst2l, bst2r}) do
    bst1
    |> put(k, v)
    |> merge(bst2l)
    |> merge(bst2r)
  end

  @doc """
  Merges two BSTs into one.

  All keys in `bst2` will be added to `bst1`. The given function will
  be invoked with the key, value1, and value2 to solve conflicts.

  ## Examples

      iex> bst1 = Purely.BST.new(a: 1, b: 2)
      iex> bst2 = Purely.BST.new(a: 3, d: 4)
      iex> Purely.BST.merge(bst1, bst2, fn _k, v1, v2 ->
      ...>   v1 + v2
      ...> end) |> Purely.BST.inorder
      [{:a, 4}, {:b, 2}, {:d, 4}]

  """
  @spec merge(bst, bst, (key, value, value -> value)) :: bst
  def merge(@empty, bst2, _), do: bst2
  def merge(bst1, @empty, _), do: bst1

  def merge(bst1, {{k, v}, bst2l, bst2r}, fun) do
    bst1
    |> merge_key(k, v, fun)
    |> merge(bst2l, fun)
    |> merge(bst2r, fun)
  end

  defp merge_key(bst, k, v, fun) do
    new_value = if has_key?(bst, k), do: fun.(k, get(bst, k), v), else: v
    put(bst, k, new_value)
  end

  @doc """
  Takes all entries corresponding to the given `keys` and extracts
  them into a separate `map`.

  Returns a tuple with the new map and the old map with removed keys.

  Keys for which there are no entries in `map` are ignored.

  ## Examples

      iex> bst = Purely.BST.new(a: 1, b: 2, c: 3)
      iex> {bst1, bst2} = Purely.BST.split(bst, [:a, :c, :e])
      iex> Purely.BST.inorder(bst1)
      [a: 1, c: 3]
      iex> Purely.BST.inorder(bst2)
      [b: 2]

  """
  @spec split(bst, Enumerable.t()) :: {bst, bst}
  def split(bst, keys) do
    Enum.reduce(keys, {new(), bst}, fn key, {bst1, bst2} ->
      if has_key?(bst2, key) do
        {value, bst2} = pop(bst2, key)
        {put(bst1, key, value), bst2}
      else
        {bst1, bst2}
      end
    end)
  end

  @doc """
  Takes all entries corresponding to the given keys and
  returns them in a new BST.

  ## Examples

      iex> bst = Purely.BST.new(a: 1, b: 2, c: 3)
      iex> Purely.BST.take(bst, [:a, :c, :e]) |> Purely.BST.inorder
      [a: 1, c: 3]

  """
  @spec take(bst, Enumerable.t()) :: bst
  def take(bst, keys) do
    {taken_bst, _} = split(bst, keys)
    taken_bst
  end

  @doc """
  Drops the given `keys` from `bst`.

  ## Examples

      iex> bst = Purely.BST.new(a: 1, b: 2, c: 3)
      iex> Purely.BST.drop(bst, [:b, :d]) |> Purely.BST.inorder
      [a: 1, c: 3]

  """
  @spec drop(bst, Enumerable.t()) :: bst
  def drop(bst, keys) do
    {_, dropped_bst} = split(bst, keys)
    dropped_bst
  end

  @doc """
  Converts `bst` to a list.

  ## Examples

      iex> Purely.BST.to_list(Purely.BST.new(a: 1))
      [a: 1]
      iex> Purely.BST.to_list(Purely.BST.new(%{1 => 2}))
      [{1, 2}]

  """
  @spec to_list(bst) :: [{key, value}]
  def to_list(bst) do
    inorder(bst)
  end

  @doc """
  Removes the value associated with `key` in `map`; returns the value
  and the new BST.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> Purely.BST.pop(bst, :a)
      {1, {}}
      iex> Purely.BST.pop(bst, :b)
      {nil, {{:a, 1}, {}, {}}}
      iex> Purely.BST.pop(bst, :b, 3)
      {3, {{:a, 1}, {}, {}}}

  """
  @spec pop(bst, key, value) :: {value, bst}
  def pop(bst, key, default \\ nil) do
    {get(bst, key, default), delete(bst, key)}
  end

  @doc """
  Lazily returns and removes the value associated with `key` in `map`.

  This is useful if the default value is very expensive to calculate or
  generally difficult to setup and teardown again.

  ## Examples

      iex> bst = Purely.BST.new(a: 1)
      iex> fun = fn ->
      ...>   # some expensive operation here
      ...>   13
      ...> end
      iex> Purely.BST.pop_lazy(bst, :a, fun)
      {1, {}}
      iex> Purely.BST.pop_lazy(bst, :b, fun)
      {13, {{:a, 1}, {}, {}}}

  """
  @spec pop_lazy(bst, key, (() -> value)) :: {value, bst}
  def pop_lazy(bst, key, fun) do
    cond do
      has_key?(bst, key) ->
        pop(bst, key)

      true ->
        pop(bst, key, fun.())
    end
  end

  @doc """
  Deletes the entry in `bst` for a specific `key`.

  If the `key` does not exist, returns `map` unchanged.

  ## Examples

      iex> bst = Purely.BST.new(a: 1, b: 2)
      iex> Purely.BST.delete(bst, :a) |> Purely.BST.inorder
      [b: 2]
      iex> Purely.BST.delete(bst, :c) |> Purely.BST.inorder
      [a: 1, b: 2]

  """
  @spec delete(bst, key) :: bst
  def delete(@empty, _), do: @empty

  def delete({{k, v}, l, r}, key) do
    cond do
      key < k ->
        build({k, v}, delete(l, key), r)

      k < key ->
        build({k, v}, l, delete(r, key))

      true ->
        promote_leftmost(l, r)
    end
  end

  # Purely a structural traversal to remove and return the leftmost
  # key-value.  This leftmost key-value will replace a recently removed
  # key.  `sibling` is the left sibling of the deleted node and will be
  # left sibling of new node.
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
