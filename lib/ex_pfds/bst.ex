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

  @spec node(any()) :: nonempty_bst
  def node(value), do: node(@empty, value, @empty)
  @spec node(bst, any(), bst) :: nonempty_bst
  def node(left, value, right) do
    {left, value, right}
  end

  @spec inorder(bst()) :: list(any())
  def inorder(bst), do: inorder(bst, []) |> Enum.reverse
  defp inorder(@empty, acc), do: acc
  defp inorder({left, value, right}, acc) do
    inorder(right, [value | inorder(left, acc)])
  end
end
