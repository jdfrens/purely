defmodule ExPfds.BinaryTree do
  @moduledoc """
  Basic operations for a basic binary tree.
  """

  @empty {}

  @typedoc "Just an empty tuple"
  @type empty :: {}
  @typedoc """
  The tree is either empty or a tuple of a value, a left tree, and a
  right tree.
  """
  @type t :: empty | {term, t, t}

  @doc """
  Counts the number of nodes along the right spine of a binary tree.
  """
  @spec length_right_spine(t) :: non_neg_integer
  def length_right_spine(@empty), do: 0
  def length_right_spine({_, _, r}), do: 1 + length_right_spine(r)
end
