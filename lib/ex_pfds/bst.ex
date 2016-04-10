defmodule ExPfds.BST do
  @moduledoc """
  Implementation of a purely functional binary search tree.
  """

  @typedoc """
  An empty tuple for an empty tree; a three-tuple (left, value, right)
  for a general node.
  """
  @type empty_bst :: {}
  @type nonempty_bst :: {bst, any(), bst}
  @type bst :: empty_bst | nonempty_bst

  @empty {}

  @spec empty() :: empty_bst
  def empty, do: @empty

  @spec build(any()) :: nonempty_bst
  def build(value), do: build(@empty, value, @empty)
  @spec build(bst, any(), bst) :: nonempty_bst
  def build(left, value, right) do
    {left, value, right}
  end

  @spec inorder(bst()) :: list(any())
  def inorder(bst), do: inorder(bst, []) |> Enum.reverse
  defp inorder(@empty, acc), do: acc
  defp inorder({left, value, right}, acc) do
    inorder(right, [value | inorder(left, acc)])
  end

  @spec insert(bst(), any()) :: bst()
  def insert(@empty, new_value) do
    build(new_value)
  end
  def insert({left, value, right}, new_value) when new_value < value do
    build(insert(left, new_value), value, right)
  end
  def insert({left, value, right}, new_value) when new_value > value do
    build(left, value, insert(right, new_value))
  end
  def insert(bst, _), do: bst
end
