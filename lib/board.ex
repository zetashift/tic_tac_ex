defmodule Board do
  @board_size 3
  def size, do: @board_size

  @max_pos @board_size * @board_size
  def max_pos, do: @max_pos

  defstruct squares: []

  def new do
    %Board{squares: Enum.map(1..@max_pos, &Square.new/1)}
  end

  # Scrumptious use of pattern matching on a function head
  def is_full?(%Board{squares: squares}) do
    not Enum.any?(squares, &Square.is_empty?/1)
  end

  # Using guards here to make sure we get an integer
  def at(%Board{squares: squares}, n) when is_integer(n) do
    Enum.at(squares, n - 1) # 0-indexing so we need to subtract 1
  end

  def print(%Board{squares: squares}) do
    IO.puts("")

    squares
    |> Enum.chunk_every(@board_size)
    |> Enum.each(&print_line/1)

    IO.puts("")
  end

  defp print_line(squares) do
    bars = String.duplicate("-", @board_size * 4 -1)
    if hd(squares).y > 1, do: IO.puts(bars)

    squares
    |> Enum.map(fn s -> s.val ||  " " end)
    |> Enum.join(" | ")
    |> pad()
    |> IO.puts()
  end

  defp pad(str), do: " " <> str <> " "
end
