defmodule ExPfds.BinaryTree do
  @empty {}

  def right_spine(tree, fun \\ &(&1)), do: right_spine(tree, fun, [])
  defp right_spine(@empty, _, spine), do: Enum.reverse(spine)
  defp right_spine({v, _, r}, fun, spine) do
    right_spine(r, fun, [fun.(v) | spine])
  end
end
