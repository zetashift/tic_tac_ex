defmodule TicTac.Game do
  alias __MODULE__

  @board_size Board.size()
  @max_pos Board.max_pos()

  defstruct [:board, :current_player, :winner, :move]

  defp end_turn(%Game{board: board, current_player: player} = game) do
    case {game.winner, Board.is_full?(board)} do
      {true, _} ->
        Board.print(board)
        player_str = player |> to_string() |> String.upcase()
        "Game Over. #{player_str} is victorious"

      {_, true} ->
        Board.print(board)
        "Game Over. It's a tie."

      _ ->
        player = other_player(player)
        main_loop(%Game{game | move: nil, current_player: player})
    end
  end

  defp get_move(%Game{} = game) do
    Board.print(game.board)

    move =
      IO.gets("Choose your next square (1-#{@max_pos})")
      |> String.trim()
      |> Integer.parse()

    case move do
      {move, _} when move in 1..@max_pos -> %Game{game | move: move}
      _ -> get_move(game)
    end
  end

  defp play_move(%Game{} = game) do
    case Board.at(game.board, game.move) do
      %{val: nil} ->
        update_square(game)

      _ ->
        IO.puts("Square is occupied!")
        player = other_player(game.current_player)
        %Game{game | current_player: player}
    end
  end

  def update_square(%Game{board: b, current_player: player, move: move} = game) do
    new_squares = Square.update_at(b.squares, move, player)
    %Game{game | board: %Board{b | squares: new_squares}}
  end

  def other_player(:x), do: :o
  def other_player(:o), do: :x
  def other_player(_), do: :error

  def main_loop(%Game{} = game) do
    # Remember |> pipe passes the result into the next function as the first argument!
    game
    |> get_move()
    |> play_move()
    |> win_check()
    |> end_turn()
  end

  def new(player1), do: %Game{board: Board.new(), current_player: player1}

  def start(player1) when player1 in [:x, :o] do
    new(player1) |> main_loop()
  end

  def start(_), do: "Invalid move!"

  # For the win checking we implement a few helper functions
  defp make_col_filter(pos), do: fn s -> s.x == Square.x(pos) end
  defp make_row_filter(pos), do: fn s -> s.y == Square.y(pos) end

  defp asc_diag_filter(square), do: square.x + square.y == @board_size + 1
  defp desc_diag_filter(square), do: square.x == square.y

  defp get_line(squares, direction, pos) do
    filter =
      case direction do
        :col -> make_col_filter(pos)
        :row -> make_row_filter(pos)
        :asc_diag -> &asc_diag_filter/1
        :desc_diag -> &desc_diag_filter/1
      end

    Enum.filter(squares, filter)
  end

  defp check_line(%Game{} = game, direction) do
    get_line(game.board.squares, direction, game.move)
    |> Enum.all?(fn square -> square.val == game.current_player end)
  end

  defp check_lines(%Game{} = game, directions) do
    Enum.any?(directions, fn dir -> check_line(game, dir) end)
  end

  def win_check(%Game{} = game) do
    winner = check_lines(game, [:col, :row, :asc_diag, :desc_diag])
    %Game{game | winner: winner}
  end
end
