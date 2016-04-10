defmodule ExPfds.BSTTest do
  use ExUnit.Case, async: true
  use ExCheck

  alias ExPfds.BST

  test "inorder traversal of empty tree" do
    assert BST.inorder(BST.new) == []
  end

  test "put single value into empty tree" do
    bst = BST.new |> BST.put(23, 23)
    assert BST.inorder(bst) == [{23,23}]
  end

  test "put several values into empty tree in order" do
    bst =
      BST.new
      |> BST.put(23, 23)
      |> BST.put(46, 46)
      |> BST.put(92, 92)
    assert BST.inorder(bst) == [{23,23}, {46,46}, {92,92}]
  end

  test "put several values into empty tree in reverse order" do
    bst =
      BST.new
      |> BST.put(92, 92)
      |> BST.put(46, 46)
      |> BST.put(23, 23)
    assert BST.inorder(bst) == [{23,23}, {46,46}, {92,92}]
  end

  test "put interesting tree through .new" do
    ks = [6, 3, 7, 9, -2, 11, 10]
    kvs = Enum.zip(ks, ks)
    bst = BST.new(kvs)
    assert BST.inorder(bst) == [{-2,-2}, {3,3}, {6,6}, {7,7}, {9,9}, {10,10}, {11,11}]
  end

  property :put do
    for_all xs in list(int) do
      xs = Enum.zip(xs, xs)
      bst = BST.new(xs)
      BST.inorder(bst) == Enum.uniq(Enum.sort(xs))
    end
  end
end
