defmodule Purely.RedBlackTreeTest do
  use ExUnit.Case, async: true
  use Quixir

  alias Purely.BinaryTree
  alias Purely.RedBlackTree

  doctest RedBlackTree

  test "inorder traversal of empty tree" do
    assert RedBlackTree.inorder(RedBlackTree.new) == []
  end

  test "put single value into empty tree" do
    tree = RedBlackTree.new |> RedBlackTree.put(23, 23)
    assert RedBlackTree.inorder(tree) == [{23,23}]
  end

  test "put several values into empty tree in order" do
    tree =
      RedBlackTree.new
      |> RedBlackTree.put(23, 23)
      |> RedBlackTree.put(46, 46)
      |> RedBlackTree.put(92, 92)
    assert RedBlackTree.inorder(tree) == [{23,23}, {46,46}, {92,92}]
  end

  test "put several values into empty tree in reverse order" do
    tree =
      RedBlackTree.new
      |> RedBlackTree.put(92, 92)
      |> RedBlackTree.put(46, 46)
      |> RedBlackTree.put(23, 23)
    assert RedBlackTree.inorder(tree) == [{23,23}, {46,46}, {92,92}]
  end

  test "put interesting tree through .new" do
    ks = [6, 3, 7, 9, -2, 11, 10]
    kvs = Enum.zip(ks, ks)
    tree = RedBlackTree.new(kvs)
    assert RedBlackTree.inorder(tree) == [{-2,-2}, {3,3}, {6,6}, {7,7}, {9,9}, {10,10}, {11,11}]
  end

  test "puts and inorder/sort" do
    ptest xs: list(of: int(min: 1, max: 5000)) do
      xs = Enum.zip(xs, xs)
      tree = RedBlackTree.new(xs)
      assert RedBlackTree.inorder(tree) == Enum.uniq(Enum.sort(xs))
    end
  end

  test "invariant: no red node has a red child" do
    ptest xs: list(of: int(min: 1, max: 5000)) do
      xs = Enum.zip(xs, xs)
      tree = RedBlackTree.new(xs)
      assert no_red_red(tree)
    end
  end

  def no_red_red(%BinaryTree{empty: true} = tree) do
    RedBlackTree.black?(tree)
  end
  def no_red_red(%BinaryTree{decoration: %{color: :black}, left: l, right: r}) do
    no_red_red(l) and no_red_red(r)
  end
  def no_red_red(%BinaryTree{decoration: %{color: :red}, left: l, right: r}) do
    RedBlackTree.black?(l) and RedBlackTree.black?(r) and
      no_red_red(l) and no_red_red(r)
  end

  test "invariant: every path from root to an empty node contains the same number of black nodes" do
    ptest xs: list(of: int(min: 1, max: 5000)) do
      xs = Enum.zip(xs, xs)
      tree = RedBlackTree.new(xs)
      assert count_black_nodes(tree)
    end
  end

  def count_black_nodes(%BinaryTree{empty: true}), do: 1
  def count_black_nodes(tree) do
    case {count_black_nodes(tree.right), count_black_nodes(tree.right)} do
      {false, _} -> false
      {_, false} -> false
      {left_count, right_count} ->
        left_count == right_count && left_count
    end
  end

  @tag :skip
  test "put_new" do
    ptest xs: list(of: int(min: 1, max: 5000)) do
      xs = Enum.zip(xs, xs)
      ys = xs |> Enum.map(fn {x,x} -> {x, x+1} end) |> Enum.shuffle
      tree = Enum.reduce(xs ++ ys, RedBlackTree.new, fn {k,v}, acc ->
        RedBlackTree.put_new(acc, k, v)
      end)
      assert RedBlackTree.inorder(tree) == Enum.uniq(Enum.sort(xs))
    end
  end

  @tag :skip
  test "put_new_lazy" do
    ptest xs: list(of: int(min: 1, max: 5000)) do
      tree = RedBlackTree.new
      tree = Enum.reduce(xs, tree, fn x, acc ->
        RedBlackTree.put_new_lazy(acc, x, fn -> x end)
      end)
      tree = Enum.reduce(xs, tree, fn x, acc ->
        RedBlackTree.put_new_lazy(acc, x, fn -> x * 2 end)
      end)
      assert RedBlackTree.inorder(tree) == Enum.uniq(Enum.sort(Enum.zip(xs, xs)))
    end
  end

  test "new from an enumerable and a transform" do
    ptest xs: list(of: int()) do
      fun = fn x -> {x, x} end
      tree = RedBlackTree.new(xs, fun)
      assert RedBlackTree.inorder(tree) == xs |> Enum.sort |> Enum.uniq |> Enum.map(fun)
    end
  end

  test "equals with many elements" do
    ptest xs: list(of: int()) do
      ys = xs |> Enum.shuffle
      tree_xs = RedBlackTree.new(Enum.zip(xs, xs))
      tree_ys = RedBlackTree.new(Enum.zip(ys, ys))
      assert RedBlackTree.equal?(tree_xs, tree_ys)
    end
  end

  test "not equals with many elements" do
    ptest xs: list(of: int(), min: 4) do
      ys = xs |> Enum.shuffle |> Enum.drop(3)
      tree_xs = RedBlackTree.new(Enum.zip(xs, xs))
      tree_ys = RedBlackTree.new(Enum.zip(ys, ys))
      refute RedBlackTree.equal?(tree_xs, tree_ys)
    end
  end

  test "get values" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*9 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      probes = random_probes(ks)
      for k <- probes do
        assert RedBlackTree.get(tree, k) == k*9
      end
    end
  end

  test "get missing values" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*20 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1*&1))
      probes = random_probes(neg_ks)
      for k <- probes do
        assert RedBlackTree.get(tree, k, k * 5) == k * 5
      end
    end
  end

  @tag :skip
  test "get_lazy values" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*9 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      probes = random_probes(ks)
      for k <- probes do
        assert RedBlackTree.get_lazy(tree, k, fn -> :error end) == k*9
      end
    end
  end

  @tag :skip
  test "get_lazy missing values" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*20 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1*&1))
      probes = random_probes(neg_ks)
      for k <- probes do
        assert RedBlackTree.get_lazy(tree, k, fn -> k * 5 end) == k * 5
      end
    end
  end

  test "update" do
    ptest xs: list(of: int(min: 1), min: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq
        |> Enum.shuffle
        |> Enum.partition(fn x -> rem(x, 2) == 0 end)

      tree = Enum.reduce(updates, RedBlackTree.new(Enum.zip(xs, xs)), fn y, acc ->
        RedBlackTree.update(acc, y, :default, &(&1 * 10))
      end)

      Enum.each(updates, fn x ->
        assert x * 10 == RedBlackTree.get(tree, x)
      end)
      Enum.each(unchanged, fn x ->
        assert x == RedBlackTree.get(tree, x)
      end)
    end
  end

  test "update missing" do
    ptest xs: list(of: int(min: 1)),
      missing: list(of: int(max: -1)) do
      tree = Enum.reduce(Enum.uniq(missing), RedBlackTree.new(Enum.zip(xs, xs)), fn y, acc ->
        RedBlackTree.update(acc, y, :default, &(&1 * 2))
      end)

      Enum.each(missing, fn x ->
        assert :default == RedBlackTree.get(tree, x)
      end)
      Enum.each(xs, fn x ->
        assert x == RedBlackTree.get(tree, x)
      end)
    end
  end

  @tag :skip
  test "update!" do
    ptest xs: list(of: int(min: 1), min: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq
        |> Enum.shuffle
        |> Enum.partition(fn x -> rem(x, 2) == 0 end)

      tree = Enum.reduce(updates, RedBlackTree.new(Enum.zip(xs, xs)), fn y, acc ->
        RedBlackTree.update!(acc, y, &(&1 * 10))
      end)

      Enum.each(updates, fn x ->
        assert x * 10 == RedBlackTree.get(tree, x)
      end)
      Enum.each(unchanged, fn x ->
        assert x == RedBlackTree.get(tree, x)
      end)
    end
  end

  @tag :skip
  test "update! missing" do
    ptest xs: list(of: int(min: 1)),
      missing: list(of: int(max: -1)) do
      tree = Enum.reduce(Enum.uniq(missing), RedBlackTree.new(Enum.zip(xs, xs)), fn y, acc ->
        try do
          RedBlackTree.update!(acc, y, &(&1 * 2))
          refute true, "should always raise error"
        rescue
          [KeyError] -> acc
        end
      end)

      Enum.each(missing, fn x ->
        assert :missing == RedBlackTree.get(tree, x, :missing)
      end)
      Enum.each(xs, fn x ->
        assert x == RedBlackTree.get(tree, x)
      end)
    end
  end

  @tag :skip
  test "get_and_update" do
    ptest xs: list(of: int(min: 1), min: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq
        |> Enum.shuffle
        |> Enum.partition(fn x -> rem(x, 2) == 0 end)

      tree = RedBlackTree.new(Enum.zip(xs, xs))
      {old_values, updated_tree} =
        Enum.reduce(updates, {[], tree}, fn y, {value_acc, tree_acc} ->
          {old_value, new_acc} = RedBlackTree.get_and_update(tree_acc, y, &({&1, &1 * 10}))
          {[old_value | value_acc], new_acc}
        end)

      assert updates == Enum.reverse(old_values)
      Enum.each(updates, fn x ->
        assert x * 10 == RedBlackTree.get(updated_tree, x)
      end)
      Enum.each(unchanged, fn x ->
        assert x == RedBlackTree.get(updated_tree, x)
      end)
    end
  end

  @tag :skip
  test "get_and_update missing" do
    ptest xs: list(of: int(min: 1)),
      missing: list(of: int(max: -1)) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      tree = Enum.reduce(Enum.uniq(missing), tree, fn y, acc ->
        {nil, tree} = RedBlackTree.get_and_update(acc, y, &({&1, :updated}))
        tree
      end)

      Enum.each(missing, fn x ->
        assert :updated == RedBlackTree.get(tree, x)
      end)
      Enum.each(xs, fn x ->
        assert x == RedBlackTree.get(tree, x)
      end)
    end
  end

  @tag :skip
  test "get_and_update!" do
    ptest xs: list(of: int(min: 1), min: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq
        |> Enum.shuffle
        |> Enum.partition(fn x -> rem(x, 2) == 0 end)

      tree = RedBlackTree.new(Enum.zip(xs, xs))
      {old_values, updated_tree} =
        Enum.reduce(updates, {[], tree}, fn y, {value_acc, tree_acc} ->
          {old_value, new_acc} = RedBlackTree.get_and_update!(tree_acc, y, &({&1, &1 * 10}))
          {[old_value | value_acc], new_acc}
        end)

      assert updates == Enum.reverse(old_values)
      Enum.each(updates, fn x ->
        assert x * 10 == RedBlackTree.get(updated_tree, x)
      end)
      Enum.each(unchanged, fn x ->
        assert x == RedBlackTree.get(updated_tree, x)
      end)
    end
  end

  @tag :skip
  test "get_and_update! missing" do
    ptest xs: list(of: int(min: 1)),
      missing: list(of: int(max: -1)) do
      tree = Enum.reduce(Enum.uniq(missing), RedBlackTree.new(Enum.zip(xs, xs)), fn y, acc ->
        try do
          RedBlackTree.get_and_update!(acc, y, &({&1, :wont_update}))
          refute true, "should always raise error"
        rescue
          [KeyError] -> acc
        end
      end)

      Enum.each(missing, fn x ->
        assert :missing == RedBlackTree.get(tree, x, :missing)
      end)
      Enum.each(xs, fn x ->
        assert x == RedBlackTree.get(tree, x)
      end)
    end
  end

  test "found with has_key?" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*3 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      probes = random_probes(ks)
      for k <- probes do
        assert RedBlackTree.has_key?(tree, k) == true
      end
    end
  end

  test "not found with has_key?" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*10 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1*&1))
      probes = random_probes(neg_ks)
      for k <- probes do
        assert RedBlackTree.has_key?(tree, k) == false
      end
    end
  end

  test "keys" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*10 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      assert RedBlackTree.keys(tree) == Enum.uniq(Enum.sort(ks))
    end
  end

  test "values" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*10 end)
      tree = RedBlackTree.new(Enum.zip(ks, vs))
      assert Enum.uniq(Enum.sort(RedBlackTree.values(tree))) == Enum.uniq(Enum.sort(vs))
    end
  end

  @tag :skip
  test "merge" do
    ptest xs: list(of: int()),
      ys: list(of: int()) do
      tree1 = RedBlackTree.new(Enum.zip(xs, xs))
      tree2 = RedBlackTree.new(Enum.zip(ys, ys))
      all = xs ++ ys
      tree12 = RedBlackTree.new(Enum.zip(all, all))
      assert RedBlackTree.inorder(RedBlackTree.merge(tree1, tree2)) == RedBlackTree.inorder(tree12)
      assert RedBlackTree.inorder(RedBlackTree.merge(tree2, tree1)) == RedBlackTree.inorder(tree12)
    end
  end

  @tag :skip
  test "merge with callback" do
    ptest xs: list(of: int(), min: 1) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      merged = RedBlackTree.merge(tree, tree, fn k, v1, v2 -> k + v1 + v2 end)
      control = RedBlackTree.new(Enum.map(xs, &{&1, 3 * &1}))
      assert RedBlackTree.inorder(merged) == RedBlackTree.inorder(control)
    end

    ptest xs: list(of: int(min: 1)),
      ys: list(of: int(max: -1)) do
      tree1 = RedBlackTree.new(Enum.zip(xs, xs))
      tree2 = RedBlackTree.new(Enum.zip(ys, ys))
      merged = RedBlackTree.merge(tree1, tree2, fn _,_,_ ->
        refute true, "should never call this" end
      )
      control = RedBlackTree.new(Enum.zip(xs ++ ys, xs ++ ys))
      assert RedBlackTree.inorder(merged) == RedBlackTree.inorder(control)
    end
  end

  @tag :skip
  test "split" do
    ptest xs: list(of: int()),
      split_count: int(min: 0, max: length(^xs)) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      split_keys = MapSet.new(xs |> Enum.shuffle |> Enum.take(split_count))
      non_split_keys = MapSet.difference(MapSet.new(xs), split_keys)
      {tree1, tree2} = RedBlackTree.split(tree, split_keys)
      assert RedBlackTree.inorder(tree1) == RedBlackTree.inorder(RedBlackTree.new(Enum.zip(split_keys, split_keys)))
      assert RedBlackTree.inorder(tree2) == RedBlackTree.inorder(RedBlackTree.new(Enum.zip(non_split_keys, non_split_keys)))
    end
  end

  @tag :skip
  test "take" do
    ptest xs: list(of: int()),
      taken_count: int(min: 0, max: length(^xs)) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      taken_keys = xs |> Enum.shuffle |> Enum.take(taken_count)
      taken_tree = RedBlackTree.take(tree, taken_keys)
      assert RedBlackTree.inorder(taken_tree) == RedBlackTree.inorder(RedBlackTree.new(Enum.zip(taken_keys, taken_keys)))
    end
  end

  @tag :skip
  test "drop" do
    ptest xs: list(of: int()),
      drop_count: int(min: 0, max: length(^xs)) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      dropped_keys = MapSet.new(xs |> Enum.shuffle |> Enum.take(drop_count))
      undropped_keys = MapSet.difference(MapSet.new(xs), dropped_keys)
      dropped_tree = RedBlackTree.drop(tree, dropped_keys)
      assert RedBlackTree.inorder(dropped_tree) == RedBlackTree.inorder(RedBlackTree.new(Enum.zip(undropped_keys, undropped_keys)))
    end
  end

  @tag :skip
  test "pop" do
    ptest xs: list(of: int(), min: 5) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      xs
      |> Enum.shuffle
      |> Enum.uniq
      |> Enum.take(3)
      |> Enum.each(fn x ->
        assert RedBlackTree.pop(tree, x) == {x, RedBlackTree.delete(tree, x)}
      end)
    end
  end

  @tag :skip
  test "pop missing keys" do
    ptest xs: list(of: int(min: 1)), probes: list(of: int(max: -1)) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      Enum.each(probes, fn p ->
        assert RedBlackTree.pop(tree, p, :missing) == {:missing, RedBlackTree.delete(tree, p)}
      end)
    end
  end

  @tag :skip
  test "pop_lazy" do
    ptest xs: list(of: int(), min: 5) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      fun = fn -> raise "do not call me!" end
      xs
      |> Enum.shuffle
      |> Enum.uniq
      |> Enum.take(3)
      |> Enum.each(fn x ->
        assert RedBlackTree.pop_lazy(tree, x, fun) == {x, RedBlackTree.delete(tree, x)}
      end)
    end
  end

  @tag :skip
  test "pop_lazy missing keys" do
    ptest xs: list(of: int(min: 1)), probes: list(of: int(max: -1)) do
      tree = RedBlackTree.new(Enum.zip(xs, xs))
      fun = fn -> :missing end
      Enum.each(probes, fn p ->
        assert RedBlackTree.pop_lazy(tree, p, fun) == {:missing, RedBlackTree.delete(tree, p)}
      end)
    end
  end

  test "delete deletes" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*88 end)
      xxtree = RedBlackTree.new(Enum.zip(ks, vs))
      probes = random_probes(ks)
      tree = Enum.reduce(probes, xxtree, fn k, acc ->
        RedBlackTree.delete(acc, k)
      end)

      for k <- probes do
        assert RedBlackTree.has_key?(tree, k) == false
      end
    end
  end

  test "delete keeps" do
    ptest ks: list(of: int(min: 1, max: 5000), min: 1) do
      vs = Enum.map(ks, fn k -> k*88 end)
      xxtree = RedBlackTree.new(Enum.zip(ks, vs))
      deleted_probes = random_probes(ks)
      probes = MapSet.difference(MapSet.new(ks), MapSet.new(deleted_probes))
      tree = Enum.reduce(deleted_probes, xxtree, fn k, acc ->
        RedBlackTree.delete(acc, k)
      end)

      for k <- probes do
        assert RedBlackTree.has_key?(tree, k), "#{k} should still be in the tree #{tree |> RedBlackTree.inorder |> inspect} #{xxtree |> RedBlackTree.inorder |> inspect}"
      end
    end
  end

  @tag :skip
  test "delete fills in the deleted node" do
    keys = [5, 3, 2, 4, 7, 6, 8]
    tree = RedBlackTree.new(Enum.zip(keys, keys)) |> RedBlackTree.delete(5)
    assert RedBlackTree.keys(tree) == [2, 3, 4, 6, 7, 8]

    keys = [2, 1, 10, 9, 8, 7, 6, 5, 4, 3]
    tree = RedBlackTree.new(Enum.zip(keys, keys)) |> RedBlackTree.delete(2)
    assert RedBlackTree.keys(tree) == [1, 3, 4, 5, 6, 7, 8, 9, 10]
  end

  @tag :skip
  test "Exercise 3.8" do
    # maximum depth <= 2 * floor(log(n+1))
  end

  def random_probes(keys, opts \\ []) do
    count = opts[:coount] || 5
    keys |> Enum.shuffle |> Enum.take(count)
  end
end
