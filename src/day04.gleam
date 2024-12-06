import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

fn debug() {
  False
}

fn test_input() {
  "MMMSXXMASM
  MSAMXMSMSA
  AMXSXMAAMM
  MSAMASMSMX
  XMASAMXAMM
  XXAMMXXAMA
  SMSMSASXSS
  SAXAMASAAA
  MAMMMXMMMM
  MXMXAXMASX"
}

pub type Coord {
  Coord(row: Int, col: Int)
}

pub type Grid =
  Dict(Coord, String)

pub type Input =
  #(Grid, List(Coord))

fn parse(input: String, find_char: String) {
  let grid = dict.new()
  let x_coords = []
  use #(grid, x_coords), line, row <- list.index_fold(
    input |> string.split("\n"),
    #(grid, x_coords),
  )

  use #(grid, x_coords), string, col <- list.index_fold(
    line |> string.trim() |> string.to_graphemes(),
    #(grid, x_coords),
  )

  let grid = dict.insert(grid, Coord(row, col), string)
  let x_coords = case string {
    x if x == find_char -> [Coord(row, col), ..x_coords]
    _ -> x_coords
  }
  #(grid, x_coords)
}

pub type Direction {
  Up
  Down
  Left
  Right
  UpLeft
  UpRight
  DownLeft
  DownRight
}

fn next_char(char: String) {
  case char {
    "X" -> "M"
    "M" -> "A"
    "A" -> "S"
    _ -> ""
  }
}

fn check(grid: Grid, x_coord: Coord, char: String, direction: Direction) {
  case dict.get(grid, x_coord) {
    Ok(match) ->
      case match == char {
        True -> check_next(grid, x_coord, char, direction)
        False -> 0
      }
    Error(Nil) -> 0
  }
}

fn check_next(grid: Grid, x_coord: Coord, char: String, direction: Direction) {
  let Coord(row, col) = x_coord

  case next_char(char) {
    "" -> 1
    next_char ->
      case direction {
        Up -> check(grid, Coord(row - 1, col), next_char, Up)
        Down -> check(grid, Coord(row + 1, col), next_char, Down)
        Left -> check(grid, Coord(row, col - 1), next_char, Left)
        Right -> check(grid, Coord(row, col + 1), next_char, Right)
        UpLeft -> check(grid, Coord(row - 1, col - 1), next_char, UpLeft)
        UpRight -> check(grid, Coord(row - 1, col + 1), next_char, UpRight)
        DownLeft -> check(grid, Coord(row + 1, col - 1), next_char, DownLeft)
        DownRight -> check(grid, Coord(row + 1, col + 1), next_char, DownRight)
      }
  }
}

pub fn part1(input: Input) {
  let #(grid, x_coords) = input
  use acc, x_coord <- list.fold(x_coords, 0)

  let sum =
    [
      check(grid, x_coord, "X", Up),
      check(grid, x_coord, "X", Down),
      check(grid, x_coord, "X", Left),
      check(grid, x_coord, "X", Right),
      check(grid, x_coord, "X", UpLeft),
      check(grid, x_coord, "X", UpRight),
      check(grid, x_coord, "X", DownLeft),
      check(grid, x_coord, "X", DownRight),
    ]
    |> int.sum

  acc + sum
}

fn check_2(grid: Grid, x_coord: Coord) {
  let Coord(row, col) = x_coord
  let diagonal1 =
    [
      dict.get(grid, Coord(row - 1, col - 1)),
      dict.get(grid, Coord(row, col)),
      dict.get(grid, Coord(row + 1, col + 1)),
    ]
    |> get_and_join

  let diagonal2 =
    [
      dict.get(grid, Coord(row - 1, col + 1)),
      dict.get(grid, Coord(row, col)),
      dict.get(grid, Coord(row + 1, col - 1)),
    ]
    |> get_and_join

  case diagonal1, diagonal2 {
    Ok("MAS"), Ok("MAS") -> 1
    Ok("SAM"), Ok("SAM") -> 1
    Ok("MAS"), Ok("SAM") -> 1
    Ok("SAM"), Ok("MAS") -> 1
    _, _ -> 0
  }
}

fn get_and_join(diagonal: List(Result(String, Nil))) {
  diagonal
  |> list.try_fold("", fn(string, char) {
    case char {
      Ok(char) -> Ok(string <> char)
      Error(Nil) -> Error(Nil)
    }
  })
}

pub fn part2(input: Input) {
  let #(grid, a_coords) = input
  use acc, a_coord <- list.fold(a_coords, 0)

  acc + check_2(grid, a_coord)
}

pub fn main() {
  utils.input(debug(), test_input(), "src/day04.input")
  // |> parse("X")
  // |> part1
  |> parse("A")
  |> part2
  |> io.debug
}
