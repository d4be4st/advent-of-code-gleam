import gleam/order
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

type Input = List(List(Int))

fn debug() {
  False
}

fn test_input() {
  "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
37 38 37 34 31"
}

fn parse(input: String) -> Input {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.trim()
    |> string.split(" ")
    |> list.map(utils.to_int)
  })
}

pub fn part1(input: Input) {
  input
  |> list.map(fn(row) { 
    scan(row, [], Started(1)) 
  })
  |> list.count(fn (level) { level != Failed(0) })
}

pub fn part2(input: Input) {
  input
  |> list.map(fn(row) { scan(row, [], Started(2)) })
  |> list.count(fn (level) { level != Failed(0) })
}

pub type Level {
  Rising(times: Int)
  Falling(times:Int)
  Started(times: Int)
  Failed(times: Int)
}

fn scan(list: List(Int), prev: List(Int), level: Level) -> Level {
  case list {
    [] -> level
    [_n1] -> level
    [n1, n2, ..rest] -> check(n1, n2, rest, prev, level)
  }
}

fn check(n1: Int, n2: Int, rest: List(Int), prev: List(Int), level: Level) -> Level {
  io.debug(#(n1, n2, rest, prev, level))
  let abs = int.absolute_value(n2 - n1)
  case abs >= 1 && abs <= 3 {
    False -> {
      failed_case(n1, n2, rest, prev, level.times)
    }
    True ->
      case level {
        Rising(times) ->
          case n1 < n2 {
            True -> scan([n2, ..rest], [n1, ..prev], Rising(times))
            False -> failed_case(n1, n2, rest, prev, times)
          }
        Falling(times) -> {
          case n1 > n2 {
            True -> scan([n2, ..rest], [n1, ..prev], Falling(times))
            False -> failed_case(n1, n2, rest, prev, times)
          }
        }
        Started(times) ->
          case int.compare(n1, n2) {
            order.Lt -> scan([n2, ..rest], [n1, ..prev], Rising(times))
            order.Gt -> scan([n2, ..rest], [n1, ..prev], Falling(times))
            order.Eq -> failed_case(n1, n2, rest, prev, times)
          }
        Failed(times) -> Failed(times)
      }
  }
}

// rewrite to use Result
fn failed_case(n1, n2, rest, prev, times) {
 case times - 1 {
    0 -> {
      io.debug(#(list.reverse(prev), [n1, n2], rest))
      Failed(0)
    }
    _ -> {
      io.debug(#(list.reverse(prev), [n1, n2], rest))
      case scan(list.flatten([list.reverse(prev), [n1], rest]), [], Started(times - 1)) {
        Failed(_) -> case scan(list.flatten([list.reverse(prev), [n2], rest]), [], Started(times - 1)) {
          Failed(_) -> case list.length(prev) {
            1 -> scan(list.flatten([[n1, n2], rest]), [], Started(times - 1))
            _ -> Failed(0)
          }
          level -> level
        }
        level -> level
      }
    }
  }
}

pub fn main() {
  utils.input(debug(), test_input(), "src/day02.input")
  |> parse
  |> part2
  |> io.debug
}
