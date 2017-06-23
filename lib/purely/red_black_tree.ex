defmodule Purely.RedBlackTree do
  alias Purely.BinaryTree

  @empty %BinaryTree{empty: true}
  @proper_empty %BinaryTree{empty: true, decoration: %{color: :black}}

  @type key :: any
  @type value :: any
  @type color :: :red | :black | :double_black | :negative_black
  @type payload :: {key, value}

  @type t :: BinaryTree.t

  def color(@empty), do: :black
  def color(%BinaryTree{decoration: %{color: color}}), do: color

  def black?(tree), do: color(tree) == :black
  def red?(tree), do: color(tree) == :red

  def black!(tree), do: update_color(tree, :black)
  def double_black!(tree), do: update_color(tree, :black)
  def red!(tree), do: update_color(tree, :red)

  defp update_color(%BinaryTree{} = tree, color) do
    %{tree | decoration: update_color(tree.decoration, color)}
  end
  defp update_color(%{} = decoration, color) do
    %{decoration | color: color}
  end

  def empty do
    @proper_empty
  end

  def new do
    empty()
  end

  def new(enumerable) do
    Enum.reduce(enumerable, new(), &flipped_put/2)
  end

  def new(enumerable, transform) do
    enumerable |> Enum.map(transform) |> new
  end

  def equal?(tree1, tree2) do
    inorder(tree2) === inorder(tree1)
  end

  defp flipped_put({key, val}, bst), do: put(bst, key, val)

  defp build(color, payload, left, right) do
    %BinaryTree{
      decoration: %{color: color},
      payload: payload,
      left: left,
      right: right
    }
  end

  def put(@empty, key, value) do
    build(:red, {key, value}, empty(), empty())
  end
  def put(tree, key, value) do
    tree |> ins(key, value) |> black!
  end

  def get(tree, key, default \\ nil)
  def get(@empty, _key, default), do: default
  def get(%BinaryTree{payload: {k, v}} = tree, key, default) do
    cond do
      key < k -> get(tree.left, key, default)
      key > k -> get(tree.right, key, default)
      true    -> v
    end
  end

  def update(tree, key, initial, fun) do
    cond do
      has_key?(tree, key) ->
        value = get(tree, key)
        put(tree, key, fun.(value))
      true ->
        put(tree, key, initial)
    end
  end

  def has_key?(@empty, _key), do: false
  def has_key?(%BinaryTree{payload: {k, _v}} = tree, key) do
    cond do
      key < k -> has_key?(tree.left, key)
      key > k -> has_key?(tree.right, key)
      true    -> true
    end
  end

  def keys(tree) do
    tree |> inorder |> Keyword.keys
  end

  def values(tree) do
    tree |> inorder |> Keyword.values
  end

  def delete(@empty, _key), do: empty()
  def delete(%BinaryTree{payload: {k, _v} = kv} = tree, key) do
    cond do
      key < k -> bubble(tree.payload, delete(tree.left, key), kv, tree.right)
      key > k -> bubble(tree.payload, tree.left, kv, delete(tree.right, key))
      true    -> remove(tree)
    end
  end

  defp remove(%BinaryTree{left: @empty, right: @empty} = tree) do
    case color(tree) do
      :red   -> black!(empty())
      :black -> double_black!(empty())
    end
  end
  defp remove(_) do
    empty
  end

  def bubble(payload, left, kv, right) do
    empty
  end

  defp ins(%BinaryTree{payload: {k, _v} = kv, left: l, right: r} = tree, key, value) do
    cond do
      key < k ->
        balance(tree, put(l, key, value), r)
      key > k ->
        balance(tree, l, put(r, key, value))
      true ->
        %{tree | payload: {k, value}}
    end
  end

  def balance_colors(@empty = tree, _), do: color(tree)
  def balance_colors(tree, 0), do: {}
  def balance_colors(tree, depth \\ 3) do
    [
      color(tree),
      balance_colors(tree.left, depth - 1),
      balance_colors(tree.right, depth - 1)
    ]
  end

  defp balance(tree, left, right) do
    case balance_colors(tree) do
      [:black, [:red, [:red], _], _] ->
        rotate(
          left,
          left.left, left.left.left, left.left.right,
          tree, left.right, right)
      [:black, [:red, _, [:red]], _] ->
        rotate(
          left.right,
          left, left.left, left.right.left,
          tree, left.right.right, right)
      [:black, _, [:red, [:red], _]] ->
        rotate(
          right.left,
          tree, left, right.left.left,
          right.right, right.left.right, right.right)
      [:black, _, [:red, _, [:red]]] ->
        rotate(
          right,
          tree, left, right.left,
          right.right, right.right.left, right.right.right)
      _ ->
        %{tree | left: left, right: right}
    end
  end

  defp rotate(root_basis,
              left_basis,  left_left,  left_right,
              right_basis, right_left, right_right) do
    %{
      root_basis |
      left: %{left_basis | left: left_left, right: left_right} |> black!,
      right: %{right_basis | left: right_left, right: right_right} |> black!
    } |> red!
  end

  defp colorize(color, {_old_color, kv}), do: {color, kv}
  defp colorize(color, %BinaryTree{} = tree) do
    %{tree | payload: colorize(color, tree.payload)}
  end

  def inorder(tree) do
    BinaryTree.inorder(tree)
  end
end
