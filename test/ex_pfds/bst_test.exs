defmodule ExPfds.BSTTest do
  use ExUnit.Case, async: true
  use ExCheck

  alias ExPfds.BST

  test "inorder traversal of empty tree" do
    assert BST.inorder(BST.empty) == []
  end

  test "insert single value into empty tree" do
    bst = BST.empty |> BST.insert(23)
    assert BST.inorder(bst) == [23]
  end

  test "insert several values into empty tree in order" do
    bst =
      BST.empty
      |> BST.insert({23,23})
      |> BST.insert({46,46})
      |> BST.insert({92,92})
    assert BST.inorder(bst) == [{23,23}, {46,46}, {92,92}]
  end

  test "insert several values into empty tree in reverse order" do
    bst =
      BST.empty
      |> BST.insert({92,92})
      |> BST.insert({46,46})
      |> BST.insert({23,23})
    assert BST.inorder(bst) == [{23,23}, {46,46}, {92,92}]
  end

  test "inorder traversal of interesting tree" do
    bst = [6, 3, 7, 9, -2, 11, 10]
    |> Enum.reduce(BST.empty, fn x, acc -> BST.insert(acc, {x,x}) end)
    assert BST.inorder(bst) == [{-2,-2}, {3,3}, {6,6}, {7,7}, {9,9}, {10,10}, {11,11}]
  end

  property :insert do
    for_all xs in list(int) do
      xs = Enum.zip(xs, xs)
      bst = Enum.reduce(xs, BST.empty, fn x, acc -> BST.insert(acc, x) end)
      BST.inorder(bst) == Enum.uniq(Enum.sort(xs))
    end
  end
end
