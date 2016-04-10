defmodule ExPfds.BST do
  @moduledoc """
  Implementation of a purely functional binary search tree.
  """

  @empty {}

  def empty, do: @empty

  def node(value), do: node(@empty, value, @empty)
  def node(left, value, right) do
    {left, value, right}
  end

  def inorder(@empty), do: []
  def inorder({left, value, right}) do
    inorder(left) ++ [value] ++ inorder(right)
  end
end
