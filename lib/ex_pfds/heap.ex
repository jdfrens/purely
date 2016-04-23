defmodule ExPfds.Heap do
  defmacro __using__(_opts) do
    quote do
      def new, do: @empty
      def new(enumerable) do
        Enum.reduce(enumerable, @empty, &(put(&2,&1)))
      end

      def sort(h), do: sort(h, [])
      defp sort(@empty, mins), do: Enum.reverse(mins)
      defp sort(h, mins) do
        sort(remove_min(h), [min(h) | mins])
      end
    end
  end
end
