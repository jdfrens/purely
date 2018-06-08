defmodule Purely.BSTTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Purely.BST

  doctest BST

  test "inorder traversal of empty tree" do
    assert BST.inorder(BST.new()) == []
  end

  test "put single value into empty tree" do
    bst = BST.new() |> BST.put(23, 23)
    assert BST.inorder(bst) == [{23, 23}]
  end

  test "put several values into empty tree in order" do
    bst =
      BST.new()
      |> BST.put(23, 23)
      |> BST.put(46, 46)
      |> BST.put(92, 92)

    assert BST.inorder(bst) == [{23, 23}, {46, 46}, {92, 92}]
  end

  test "put several values into empty tree in reverse order" do
    bst =
      BST.new()
      |> BST.put(92, 92)
      |> BST.put(46, 46)
      |> BST.put(23, 23)

    assert BST.inorder(bst) == [{23, 23}, {46, 46}, {92, 92}]
  end

  test "put interesting tree through .new" do
    ks = [6, 3, 7, 9, -2, 11, 10]
    kvs = Enum.zip(ks, ks)
    bst = BST.new(kvs)
    assert BST.inorder(bst) == [{-2, -2}, {3, 3}, {6, 6}, {7, 7}, {9, 9}, {10, 10}, {11, 11}]
  end

  property "puts and inorder/sort" do
    check all xs <- list_of(integer(1..5000)) do
      xs = Enum.zip(xs, xs)
      bst = BST.new(xs)
      assert BST.inorder(bst) == Enum.uniq(Enum.sort(xs))
    end
  end

  property "put_new" do
    check all xs <- list_of(integer(1..5000)) do
      xs = Enum.zip(xs, xs)
      ys = xs |> Enum.map(fn {x, x} -> {x, x + 1} end) |> Enum.shuffle()

      bst =
        Enum.reduce(xs ++ ys, BST.new(), fn {k, v}, acc ->
          BST.put_new(acc, k, v)
        end)

      assert BST.inorder(bst) == Enum.uniq(Enum.sort(xs))
    end
  end

  property "put_new_lazy" do
    check all xs <- list_of(integer(1..5000)) do
      bst = BST.new()

      bst =
        Enum.reduce(xs, bst, fn x, acc ->
          BST.put_new_lazy(acc, x, fn -> x end)
        end)

      bst =
        Enum.reduce(xs, bst, fn x, acc ->
          BST.put_new_lazy(acc, x, fn -> x * 2 end)
        end)

      assert BST.inorder(bst) == Enum.uniq(Enum.sort(Enum.zip(xs, xs)))
    end
  end

  property "new from an enumerable and a transform" do
    check all xs <- list_of(integer()) do
      fun = fn x -> {x, x} end
      bst = BST.new(xs, fun)
      assert BST.inorder(bst) == xs |> Enum.sort() |> Enum.uniq() |> Enum.map(fun)
    end
  end

  property "equals with many elements" do
    check all xs <- list_of(integer()) do
      ys = xs |> Enum.shuffle()
      bst_xs = BST.new(Enum.zip(xs, xs))
      bst_ys = BST.new(Enum.zip(ys, ys))
      assert BST.equal?(bst_xs, bst_ys)
    end
  end

  property "not equals with many elements" do
    check all xs <- uniq_list_of(resize(integer(), 100), min_length: 4) do
      ys = xs |> Enum.shuffle() |> Enum.drop(3)
      bst_xs = BST.new(Enum.zip(xs, xs))
      bst_ys = BST.new(Enum.zip(ys, ys))
      refute BST.equal?(bst_xs, bst_ys)
    end
  end

  property "get values" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 9 end)
      bst = BST.new(Enum.zip(ks, vs))
      probes = random_probes(ks)

      for k <- probes do
        assert BST.get(bst, k) == k * 9
      end
    end
  end

  property "get missing values" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 20 end)
      bst = BST.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1 * &1))
      probes = random_probes(neg_ks)

      for k <- probes do
        assert BST.get(bst, k, k * 5) == k * 5
      end
    end
  end

  property "get_lazy values" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 9 end)
      bst = BST.new(Enum.zip(ks, vs))
      probes = random_probes(ks)

      for k <- probes do
        assert BST.get_lazy(bst, k, fn -> :error end) == k * 9
      end
    end
  end

  property "get_lazy missing values" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 20 end)
      bst = BST.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1 * &1))
      probes = random_probes(neg_ks)

      for k <- probes do
        assert BST.get_lazy(bst, k, fn -> k * 5 end) == k * 5
      end
    end
  end

  property "update" do
    check all xs <- list_of(positive_integer(), min_length: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq()
        |> Enum.shuffle()
        |> Enum.split_with(fn x -> rem(x, 2) == 0 end)

      bst =
        Enum.reduce(updates, BST.new(Enum.zip(xs, xs)), fn y, acc ->
          BST.update(acc, y, :default, &(&1 * 10))
        end)

      Enum.each(updates, fn x ->
        assert x * 10 == BST.get(bst, x)
      end)

      Enum.each(unchanged, fn x ->
        assert x == BST.get(bst, x)
      end)
    end
  end

  property "update missing" do
    check all xs <- list_of(float(min: 1.0)),
              missing <- list_of(float(max: -1.0)) do
      bst =
        Enum.reduce(Enum.uniq(missing), BST.new(Enum.zip(xs, xs)), fn y, acc ->
          BST.update(acc, y, :default, &(&1 * 2))
        end)

      Enum.each(missing, fn x ->
        assert :default == BST.get(bst, x)
      end)

      Enum.each(xs, fn x ->
        assert x == BST.get(bst, x)
      end)
    end
  end

  property "update!" do
    check all xs <- list_of(positive_integer(), min_length: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq()
        |> Enum.shuffle()
        |> Enum.split_with(fn x -> rem(x, 2) == 0 end)

      bst =
        Enum.reduce(updates, BST.new(Enum.zip(xs, xs)), fn y, acc ->
          BST.update!(acc, y, &(&1 * 10))
        end)

      Enum.each(updates, fn x ->
        assert x * 10 == BST.get(bst, x)
      end)

      Enum.each(unchanged, fn x ->
        assert x == BST.get(bst, x)
      end)
    end
  end

  property "update! missing" do
    check all xs <- list_of(float(min: 1)),
              missing <- list_of(float(max: -1)) do
      bst =
        Enum.reduce(Enum.uniq(missing), BST.new(Enum.zip(xs, xs)), fn y, acc ->
          try do
            BST.update!(acc, y, &(&1 * 2))
            refute true, "should always raise error"
          rescue
            [KeyError] -> acc
          end
        end)

      Enum.each(missing, fn x ->
        assert :missing == BST.get(bst, x, :missing)
      end)

      Enum.each(xs, fn x ->
        assert x == BST.get(bst, x)
      end)
    end
  end

  property "get_and_update" do
    check all xs <- list_of(positive_integer(), min_length: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq()
        |> Enum.shuffle()
        |> Enum.split_with(fn x -> rem(x, 2) == 0 end)

      bst = BST.new(Enum.zip(xs, xs))

      {old_values, updated_bst} =
        Enum.reduce(updates, {[], bst}, fn y, {value_acc, bst_acc} ->
          {old_value, new_acc} = BST.get_and_update(bst_acc, y, &{&1, &1 * 10})
          {[old_value | value_acc], new_acc}
        end)

      assert updates == Enum.reverse(old_values)

      Enum.each(updates, fn x ->
        assert x * 10 == BST.get(updated_bst, x)
      end)

      Enum.each(unchanged, fn x ->
        assert x == BST.get(updated_bst, x)
      end)
    end
  end

  property "get_and_update missing" do
    check all xs <- list_of(float(min: 1)),
              missing <- list_of(float(max: -1)) do
      bst = BST.new(Enum.zip(xs, xs))

      bst =
        Enum.reduce(Enum.uniq(missing), bst, fn y, acc ->
          {nil, bst} = BST.get_and_update(acc, y, &{&1, :updated})
          bst
        end)

      Enum.each(missing, fn x ->
        assert :updated == BST.get(bst, x)
      end)

      Enum.each(xs, fn x ->
        assert x == BST.get(bst, x)
      end)
    end
  end

  property "get_and_update!" do
    check all xs <- list_of(positive_integer(), min_length: 5) do
      {updates, unchanged} =
        xs
        |> Enum.uniq()
        |> Enum.shuffle()
        |> Enum.split_with(fn x -> rem(x, 2) == 0 end)

      bst = BST.new(Enum.zip(xs, xs))

      {old_values, updated_bst} =
        Enum.reduce(updates, {[], bst}, fn y, {value_acc, bst_acc} ->
          {old_value, new_acc} = BST.get_and_update!(bst_acc, y, &{&1, &1 * 10})
          {[old_value | value_acc], new_acc}
        end)

      assert updates == Enum.reverse(old_values)

      Enum.each(updates, fn x ->
        assert x * 10 == BST.get(updated_bst, x)
      end)

      Enum.each(unchanged, fn x ->
        assert x == BST.get(updated_bst, x)
      end)
    end
  end

  property "get_and_update! missing" do
    check all xs <- list_of(float(min: 1)),
              missing <- list_of(float(max: -1)) do
      bst =
        Enum.reduce(Enum.uniq(missing), BST.new(Enum.zip(xs, xs)), fn y, acc ->
          try do
            BST.get_and_update!(acc, y, &{&1, :wont_update})
            refute true, "should always raise error"
          rescue
            [KeyError] -> acc
          end
        end)

      Enum.each(missing, fn x ->
        assert :missing == BST.get(bst, x, :missing)
      end)

      Enum.each(xs, fn x ->
        assert x == BST.get(bst, x)
      end)
    end
  end

  property "found with has_key?" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 3 end)
      bst = BST.new(Enum.zip(ks, vs))
      probes = random_probes(ks)

      for k <- probes do
        assert BST.has_key?(bst, k) == true
      end
    end
  end

  property "not found with has_key?" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 10 end)
      bst = BST.new(Enum.zip(ks, vs))
      neg_ks = Enum.map(ks, &(-1 * &1))
      probes = random_probes(neg_ks)

      for k <- probes do
        assert BST.has_key?(bst, k) == false
      end
    end
  end

  property "keys" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 10 end)
      bst = BST.new(Enum.zip(ks, vs))
      assert BST.keys(bst) == Enum.uniq(Enum.sort(ks))
    end
  end

  property "values" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 10 end)
      bst = BST.new(Enum.zip(ks, vs))
      assert Enum.uniq(Enum.sort(BST.values(bst))) == Enum.uniq(Enum.sort(vs))
    end
  end

  property "merge" do
    check all xs <- list_of(integer()),
              ys <- list_of(integer()) do
      bst1 = BST.new(Enum.zip(xs, xs))
      bst2 = BST.new(Enum.zip(ys, ys))
      all = xs ++ ys
      bst12 = BST.new(Enum.zip(all, all))
      assert BST.inorder(BST.merge(bst1, bst2)) == BST.inorder(bst12)
      assert BST.inorder(BST.merge(bst2, bst1)) == BST.inorder(bst12)
    end
  end

  property "merge with callback" do
    check all xs <- list_of(integer(), min_length: 1) do
      bst = BST.new(Enum.zip(xs, xs))
      merged = BST.merge(bst, bst, fn k, v1, v2 -> k + v1 + v2 end)
      control = BST.new(Enum.map(xs, &{&1, 3 * &1}))
      assert BST.inorder(merged) == BST.inorder(control)
    end

    check all xs <- list_of(float(min: 1)),
              ys <- list_of(float(max: -1)) do
      bst1 = BST.new(Enum.zip(xs, xs))
      bst2 = BST.new(Enum.zip(ys, ys))

      merged =
        BST.merge(bst1, bst2, fn _, _, _ ->
          refute true, "should never call this"
        end)

      control = BST.new(Enum.zip(xs ++ ys, xs ++ ys))
      assert BST.inorder(merged) == BST.inorder(control)
    end
  end

  property "split" do
    check all xs <- list_of(integer()),
              split_count <- integer(0..length(xs)) do
      bst = BST.new(Enum.zip(xs, xs))
      split_keys = MapSet.new(xs |> Enum.shuffle() |> Enum.take(split_count))
      non_split_keys = MapSet.difference(MapSet.new(xs), split_keys)
      {bst1, bst2} = BST.split(bst, split_keys)
      assert BST.inorder(bst1) == BST.inorder(BST.new(Enum.zip(split_keys, split_keys)))
      assert BST.inorder(bst2) == BST.inorder(BST.new(Enum.zip(non_split_keys, non_split_keys)))
    end
  end

  property "take" do
    check all xs <- list_of(integer()),
              taken_count <- integer(0..length(xs)) do
      bst = BST.new(Enum.zip(xs, xs))
      taken_keys = xs |> Enum.shuffle() |> Enum.take(taken_count)
      taken_bst = BST.take(bst, taken_keys)
      assert BST.inorder(taken_bst) == BST.inorder(BST.new(Enum.zip(taken_keys, taken_keys)))
    end
  end

  property "drop" do
    check all xs <- list_of(integer()),
              drop_count <- integer(0..length(xs)) do
      bst = BST.new(Enum.zip(xs, xs))
      dropped_keys = MapSet.new(xs |> Enum.shuffle() |> Enum.take(drop_count))
      undropped_keys = MapSet.difference(MapSet.new(xs), dropped_keys)
      dropped_bst = BST.drop(bst, dropped_keys)

      assert BST.inorder(dropped_bst) ==
               BST.inorder(BST.new(Enum.zip(undropped_keys, undropped_keys)))
    end
  end

  property "pop" do
    check all xs <- list_of(integer(), min_length: 5) do
      bst = BST.new(Enum.zip(xs, xs))

      xs
      |> Enum.shuffle()
      |> Enum.uniq()
      |> Enum.take(3)
      |> Enum.each(fn x ->
        assert BST.pop(bst, x) == {x, BST.delete(bst, x)}
      end)
    end
  end

  property "pop missing keys" do
    check all xs <- list_of(float(min: 1)),
              probes <- list_of(float(max: -1)) do
      bst = BST.new(Enum.zip(xs, xs))

      Enum.each(probes, fn p ->
        assert BST.pop(bst, p, :missing) == {:missing, BST.delete(bst, p)}
      end)
    end
  end

  property "pop_lazy" do
    check all xs <- list_of(integer(), min_length: 5) do
      bst = BST.new(Enum.zip(xs, xs))
      fun = fn -> raise "do not call me!" end

      xs
      |> Enum.shuffle()
      |> Enum.uniq()
      |> Enum.take(3)
      |> Enum.each(fn x ->
        assert BST.pop_lazy(bst, x, fun) == {x, BST.delete(bst, x)}
      end)
    end
  end

  property "pop_lazy missing keys" do
    check all xs <- list_of(float(min: 1.0)),
              probes <- list_of(float(max: -1.0)) do
      bst = BST.new(Enum.zip(xs, xs))
      fun = fn -> :missing end

      Enum.each(probes, fn p ->
        assert BST.pop_lazy(bst, p, fun) == {:missing, BST.delete(bst, p)}
      end)
    end
  end

  property "delete" do
    check all ks <- list_of(integer(1..5000), min_length: 1) do
      vs = Enum.map(ks, fn k -> k * 88 end)
      xxbst = BST.new(Enum.zip(ks, vs))
      probes = random_probes(ks)
      bst = Enum.reduce(probes, xxbst, fn k, acc -> BST.delete(acc, k) end)

      for k <- probes do
        assert BST.has_key?(bst, k) == false
      end
    end
  end

  test "delete fills in the deleted node" do
    keys = [5, 3, 2, 4, 7, 6, 8]
    bst = BST.new(Enum.zip(keys, keys)) |> BST.delete(5)
    assert BST.keys(bst) == [2, 3, 4, 6, 7, 8]

    keys = [2, 1, 10, 9, 8, 7, 6, 5, 4, 3]
    bst = BST.new(Enum.zip(keys, keys)) |> BST.delete(2)
    assert BST.keys(bst) == [1, 3, 4, 5, 6, 7, 8, 9, 10]
  end

  def random_probes(keys, count \\ 5) do
    keys |> Enum.shuffle() |> Enum.take(count)
  end
end
