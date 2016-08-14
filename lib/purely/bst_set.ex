defmodule Purely.BSTSet do
  alias Purely.BST

  @type empty :: BST.empty
  @type t :: empty | BST.t

  @spec new() :: empty
  def new do
    BST.new
  end
  @spec new(Enum.t) :: t
  def new(enumerable) do
    Enum.reduce(enumerable, BST.new, &(put(&2,&1)))
  end
  # TODO: new(enumerable, transform)

  @spec put(t, term) :: t
  def put(set, value) do
    BST.put(set, value, value)
  end

  @spec member?(t, term) :: boolean
  def member?(set, value) do
    BST.has_key?(set, value)
  end

  @spec to_list(t) :: [term]
  def to_list(set) do
    BST.keys(set)
  end

  # TODO: size(set)
  # TODO: delete(set, term)
  # TODO: difference(set1, set2)
  # TODO: disjoint?(set1, set2)
  # TODO: equal?(set1, set2)
  # TODO: intersection(set1, set2)
  # TODO: subset?(set1, set2)
  # TODO: union(set1, set2)
end
