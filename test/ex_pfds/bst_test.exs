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

  @tag iterations: 20
  property "found with .get" do
    for_all ks in non_empty(list(pos_integer)) do
      vs = Enum.map(ks, fn k -> "#{k} val" end)
      bst = BST.new(Enum.zip(ks, vs))
      probes = ks |> Enum.take(5)
      for_all k in elements(probes) do
        BST.get(bst, k) == "#{Integer.to_string(k)} val"
      end
    end
  end

  @tag iterations: 20
  property "not found with .get" do
    for_all ks in non_empty(list(pos_integer)) do
      vs = Enum.map(ks, fn k -> "#{k} val" end)
      bst = BST.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1*&1))
      probes = neg_ks |> Enum.take(5)
      for_all k in elements(probes) do
        BST.get(bst, k, k * 5) == k * 5
      end
    end
  end

  @tag iterations: 20
  property "found with .has_key?" do
    for_all ks in non_empty(list(pos_integer)) do
      vs = Enum.map(ks, fn k -> "#{k} val" end)
      bst = BST.new(Enum.zip(ks, vs))
      probes = ks |> Enum.take(5)
      for_all k in elements(probes) do
        BST.has_key?(bst, k) == true
      end
    end
  end

  @tag iterations: 20
  property "not found with .has_key?" do
    for_all ks in non_empty(list(pos_integer)) do
      vs = Enum.map(ks, fn k -> "#{k} val" end)
      bst = BST.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1*&1))
      probes = neg_ks |> Enum.shuffle |> Enum.take(5)
      for_all k in elements(probes) do
        BST.has_key?(bst, k) == false
      end
    end
  end

  property :keys do
    for_all ks in non_empty(list(pos_integer)) do
      vs = Enum.map(ks, fn k -> "#{k} val" end)
      bst = BST.new(Enum.zip(ks, vs))
      BST.keys(bst) == Enum.uniq(Enum.sort(ks))
    end
  end
end
