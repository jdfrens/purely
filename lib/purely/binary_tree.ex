defmodule Purely.BinaryTree do
  @moduledoc """
  Basic operations for a basic binary tree.
  """

  alias __MODULE__

  defstruct empty: false, decoration: %{},
    payload: nil, left: nil, right: nil

  @type payload :: any
  @type t :: %Purely.BinaryTree{empty: boolean, decoration: map, payload: payload, left: Purely.BinaryTree.t, right: Purely.BinaryTree.t}

  def empty, do: %BinaryTree{empty: true}

  def inorder(tree), do: Enum.reverse(inorder(tree, []))
  defp inorder(%BinaryTree{empty: true}, acc), do: acc
  defp inorder(%BinaryTree{payload: payload, left: l, right: r}, acc) do
    inorder(r, [payload | inorder(l, acc)])
  end

  @doc """
  Counts the number of nodes along the right spine of a binary tree.
  """
  @spec length_right_spine(t) :: non_neg_integer
  def length_right_spine(%BinaryTree{empty: true}), do: 0
  def length_right_spine(%BinaryTree{right: r}) do
    1 + length_right_spine(r)
  end
end
