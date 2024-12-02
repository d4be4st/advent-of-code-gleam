import gleam/dict
import gleam/io
import gleam/int
import gleam/list
import gleam/string
import utils
import simplifile
import gleam/option.{None, Some}

fn debug() { False }

fn test_input() {
  "3   4
4   3
2   5
1   3
3   9
3   3"
}

fn input() -> String {
  case debug() {
    True -> test_input()
    False -> {
      let assert Ok(input) = simplifile.read("src/day01.input")
      input
    }
  }
}

fn parse(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.fold(#([], []), fn(acc, line) {
    let assert [n1, n2] =
      line
      |> string.split("   ") 
      |> list.map(utils.to_int)

    #([n1, ..acc.0], [n2, ..acc.1])
  })
}

pub fn part1(lists: #(List(Int), List(Int))) {
  let sorted1 = list.sort(lists.0, int.compare)
  let sorted2 = list.sort(lists.1, int.compare)

  list.map2(sorted1, sorted2, fn(a, b) {
    int.absolute_value(b - a)
  })
  |> int.sum
  |> io.debug
}

pub fn part2(lists: #(List(Int), List(Int))) {
  lists.0
  |> list.fold(dict.new(), fn(acc, number) {
    let count = list.count(lists.1, fn(n) { n == number })
    let increment = fn(x) {
      case x {
        Some(old) -> old + count
        None -> count
      }
    }
    dict.upsert(acc, number, increment)
  })
  |> dict.fold(0, fn(acc, key, value) {
    acc + key * value 
  })
}

pub fn main() {
  input()
  |> parse
  |> part2
  |> io.debug
}
