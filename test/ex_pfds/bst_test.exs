defmodule ExPfds.BSTTest do
  use ExUnit.Case, async: true

  alias ExPfds.BST

  test "inorder traversal of empty tree" do
    assert BST.inorder(BST.empty) == []
  end

  test "inorder traversal of singleton tree" do
    assert BST.inorder(BST.node(5)) == [5]
  end

  test "inorder traversal of two-level tree" do
    bst = BST.node(BST.node(3), 6, BST.node(9))
    assert BST.inorder(bst) == [3, 6, 9]
  end

  test "inorder traversal of interesting tree" do
    bst = BST.node(
      BST.node(BST.node(-2), 3, BST.empty),
      6,
      BST.node(
        BST.node(7),
        9,
        BST.node(BST.empty, 10, BST.node(11))))
    assert BST.inorder(bst) == [-2, 3, 6, 7, 9, 10, 11]
  end
end
