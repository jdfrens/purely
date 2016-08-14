defmodule Purely.Heap do
  defmacro __using__(empty_type: empty_type, type: type) do
    quote do
      @spec new() :: unquote(empty_type)
      def new, do: @empty
      @spec new(Enum.t) :: unquote(type)
      def new(enumerable) do
        Enum.reduce(enumerable, @empty, &(put(&2,&1)))
      end

      @spec sort(unquote(type)) :: Enum.t
      def sort(h), do: sort(h, [])
      defp sort(@empty, mins), do: Enum.reverse(mins)
      defp sort(h, mins) do
        sort(remove_min(h), [min(h) | mins])
      end
    end
  end
end
