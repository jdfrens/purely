defmodule ExPfds.BSTTest do
  use ExUnit.Case, async: true
  use ExCheck

  alias ExPfds.BST

  test "inorder traversal of empty tree" do
    assert BST.inorder(BST.empty) == []
  end

  test "inorder traversal of singleton tree" do
    assert BST.inorder(BST.build(5)) == [5]
  end

  test "inorder traversal of two-level tree" do
    bst = BST.build(BST.build(3), 6, BST.build(9))
    assert BST.inorder(bst) == [3, 6, 9]
  end

  test "inorder traversal of interesting tree" do
    bst = BST.build(
      BST.build(BST.build(-2), 3, BST.empty),
      6,
      BST.build(
        BST.build(7),
        9,
        BST.build(BST.empty, 10, BST.build(11))))
    assert BST.inorder(bst) == [-2, 3, 6, 7, 9, 10, 11]
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

  property :insert do
    for_all xs in list(int) do
      xs = Enum.zip(xs, xs)
      bst = Enum.reduce(xs, BST.empty, fn x, acc -> BST.insert(acc, x) end)
      BST.inorder(bst) == Enum.uniq(Enum.sort(xs))
    end
  end
end
