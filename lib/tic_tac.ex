defmodule TicTac do
  alias TicTac.Game

  def play() do
    player = IO.gets("Who plays first, x or o?") |> String.trim()

    case player do
      "x" -> Game.start(:x)
      "o" -> Game.start(:o)
      _ -> "Invalid move!"
    end
  end
end
