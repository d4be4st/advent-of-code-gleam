import gleam/string
import gleam/int
import gleam/list
import gleam/option
import gleam/io
import gleam/regexp
import utils

fn debug() {
  False
}

fn test_input() {
  "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
}

fn multiply(match: regexp.Match) {
  let assert [option.Some(_), option.Some(a), option.Some(b)] = match.submatches
  utils.to_int(a) * utils.to_int(b)
}

fn loop(matches: List(regexp.Match), acc: List(Int), active: Bool) {
  case matches {
    [] -> #(acc, active)
    [match, ..rest] -> {
      case match.content {
        "do()" -> loop(rest, acc, True)
        "don't()" -> loop(rest, acc, False)
        _ -> case active {
          True -> loop(rest, [multiply(match), ..acc], True)
          False -> loop(rest, acc, False)
        }
      }
    }
  }
}

pub fn part1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\(([0-9]+),([0-9]+)\\)")

  input
  |> string.split("\n")
  |> list.flat_map(fn(line) {
    regexp.scan(re, line)
    |> list.map(multiply)
  })
  |> int.sum
}

pub fn part2(input: String) {
  let assert Ok(re) = regexp.from_string("(mul\\(([0-9]+),([0-9]+)\\)|do\\(\\)|don't\\(\\))")

  input
  |> string.split("\n")
  |> list.fold(#(0, True), fn(res, line) {
    let #(acc, active) = res
    let #(matches, new_active) =
      regexp.scan(re, line)
      |> loop([], active)
    #(acc + int.sum(matches), new_active)
  })
}

pub fn main() {
  utils.input(debug(), test_input(), "src/day03.input")
  |> part2
  |> io.debug
}
