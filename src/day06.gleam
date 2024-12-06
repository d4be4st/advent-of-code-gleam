import gleam/set.{type Set}
import gleam/dict
import gleam/list
import gleam/string
import utils
import gleam/io

fn debug() {
  False
}

fn test_input() {
"....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."
}

pub type Input = #(dict.Dict(Position, Marker), Position)

type Position = #(Int, Int)

type Grid = dict.Dict(Position, Marker)

pub type Marker {
  Empty
  Obstacle
  Start
}

pub type Direction {
  Up
  Down
  Left
  Right
}

pub fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), #(0, 0)), fn(acc, line, row) {
    line
    |> string.trim
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, col) {
      let #(grid, start) = acc
      let grid =
        dict.insert(grid, #(row, col), case char {
          "." -> Empty
          "^" -> Empty
          "#" -> Obstacle
          _ -> Empty
        })

      case char {
        "^" -> #(grid, #(row, col))
        _ -> #(grid, start)
      }
    })
  })

}

pub fn part1(input: Input) {
  let #(grid, start) = input
  let visited = set.new()
  move(grid, start, Up, set.insert(visited, start))
  |> set.size
}

fn move(grid: Grid, position: Position, direction: Direction, visited: Set(Position)) {
  let new_position = new_position(position, direction)
  case dict.get(grid, new_position) {
    Ok(Empty) | Ok(Start) -> {
      let visited = set.insert(visited, new_position)
      move(grid, new_position, direction, visited)
    }
    Ok(Obstacle) -> move(grid, position, rotate(direction), visited)
    _ -> visited
  }
}

fn new_position(position: Position, direction: Direction) {
  let #(row, col) = position
  let #(new_row, new_col) = case direction {
    Up -> #(row - 1, col)
    Down -> #(row + 1, col)
    Left -> #(row, col - 1)
    Right -> #(row, col + 1)
  }
  #(new_row, new_col)
}

fn rotate(direction: Direction) {
  case direction {
    Up -> Right
    Down -> Left
    Left -> Up
    Right -> Down
  }
}

pub fn part2(input: Input) {
  let #(grid, start) = input
  loop2(grid, start, Up, set.new(), set.new())
  |> set.size
}

fn loop2(grid: Grid, position: Position, direction: Direction, visited: Set(Position), looping: Set(Position)) {
  let new_position = new_position(position, direction)
  case dict.get(grid, new_position) {
    Ok(Empty) | Ok(Start) -> {
      case set.contains(visited, new_position) {
        True -> loop2(grid, new_position, direction, visited, looping)
        False -> {
          let visited = set.insert(visited, new_position)
          let new_grid = dict.insert(grid, new_position, Obstacle)
          case check_loop(new_grid, position, direction, set.new()) {
            True -> loop2(grid, new_position, direction, visited, set.insert(looping, new_position))
            False -> loop2(grid, new_position, direction, visited, looping)
          }
        }
      }
    }
    Ok(Obstacle) -> loop2(grid, position, rotate(direction), visited, looping)
    Error(_) -> looping
  }
}

pub fn print(grid: Grid, position: Position, direction: Direction) {
  let grid = dict.insert(grid, position, Start)
  list.range(0, 10)
  |> list.map(fn(row) {
    list.range(0, 10)
    |> list.map(fn(col) {
      case dict.get(grid, #(row, col)) {
        Ok(Empty) -> "."
        Ok(Start) -> case direction {
          Up -> "^"
          Down -> "v"
          Left -> "<"
          Right -> ">"
        }
        Ok(Obstacle) -> "#"
        Error(_) -> ""
      }
    })
    |> string.join("")
    |> io.debug
  })
}

fn check_loop(grid: Grid, position: Position, direction: Direction, visited: Set(#(Position, Direction))) {
  let new_position = new_position(position, direction)
  case dict.get(grid, new_position) {
    Ok(Empty) | Ok(Start) -> {
      check_loop(grid, new_position, direction, visited)
    }
    Ok(Obstacle) -> {
      case set.contains(visited, #(position, direction)) {
        True -> {
          // print(grid, position, direction)
          True
        }
        False -> {
          let visited = set.insert(visited, #(position, direction))
          check_loop(grid, position, rotate(direction), visited)
        }
      }
    }
    Error(_) -> False
  }
}

pub fn main() {
  utils.input(debug(), test_input(), "src/day06.input")
  |> parse
  // |> part1
  |> part2
  |> io.debug
}
