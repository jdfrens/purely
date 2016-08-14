defmodule ExPfds.BinaryTree do
  @empty {}

  @type empty :: {}
  @type t :: empty | {term, t, t}

  @doc """
  Counts the number of nodes along the right spine of a binary tree.
  """
  @spec length_right_spine(t) :: non_neg_integer
  def length_right_spine(@empty), do: 0
  def length_right_spine({_, _, r}), do: 1 + length_right_spine(r)
end
