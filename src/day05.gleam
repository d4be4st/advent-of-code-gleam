import gleam/int
import gleam/yielder
import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import utils
import gleam/io
import gleam/option.{None, Some}

fn debug() {
  False
}

fn test_input() {
"47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"
}

pub type Rules = Dict(Int, Dict(Int, Bool))
pub type Pages = List(List(Int)) 
pub type Input = #(Rules, List(List(Int)))

pub fn parse(input: String) {
  let assert [rules, pages] = input |> string.split("\n\n")
  let rules =
    rules
    |> string.trim()
    |> string.split("\n")
    |> list.fold(dict.new(), parse_rules)

  let pages = 
    pages
    |> string.trim()
    |> string.split("\n")
    |> list.map(parse_pages)

  #(rules, pages)
}

fn parse_rules(acc: Rules, rule: String) {
  let assert [a, b] = rule |> string.split("|") |> list.map(utils.to_int)
  acc
  |> dict.upsert(a, fn(x) {
    case x {
      Some(x) -> dict.insert(x, b, True)
      None -> dict.from_list([#(b, True)])
    }
  })
  |> dict.upsert(b, fn(x) {
    case x {
      Some(d) -> d
      None -> dict.new()
    }
  })
}

fn parse_pages(page: String) {
  page
  |> string.split(",")
  |> list.map(utils.to_int)
}

pub fn prepare(input: Input) {
  let #(rules, pages) = input

  pages
  |> list.fold(#([], []), fn(acc: #(List(List(Int)), List(List(Int))), page) {
    let #(valid_list, invalid_list) = acc
    let valid =
      page
      |> list.window(2)
      |> list.all(fn(pair) {
        let assert [a, b] = pair
        check(a, b, rules)
      })

    case valid {
      True -> #([page, ..valid_list], invalid_list)
      False -> #(valid_list, [page, ..invalid_list])
    }
  })
}

fn find_median(list) {
  let size = list.length(list)
  let assert Ok(median) = yielder.at(yielder.from_list(list), size / 2)
  median
}

fn check(a: Int, b: Int, rules: Rules) {
  // get a from rules dict
  case dict.get(rules, a) {
    // if exist check if b is its child
    Ok(prev) -> case dict.get(prev, b) {
      // if yes, then sort is ok
      Ok(_) -> True
      // if not, check if b is in rules dict
      Error(_) -> case dict.get(rules, b) {
        // if it is then sort is not ok
        Ok(_) -> False
        // if its not then it means that it does not break the rules
        Error(_) -> True
      }
    }
    // if its not it does not break the rules
    Error(_) -> True
  }
}

pub fn part1(acc: #(List(List(Int)), List(List(Int)))) {
  let #(valid_list, _) = acc
  valid_list
  |> list.map(find_median)
  |> int.sum
}

pub fn part2(acc: #(List(List(Int)), List(List(Int))), rules: Rules) {
  let #(_, invalid_pages) = acc

  invalid_pages
  |> list.map(fn(page) {
    page
    |> sort(rules)
    |> find_median
  })
  |> int.sum
}

fn sort(page: List(Int), rules: Rules) {
  let assert [a, ..rest] = page
  sort_impl(rules, rest, [a])
}

fn sort_impl(rules: Rules, left: List(Int), traversed: List(Int)) {
  case left {
    [] -> traversed
    [a, ..rest] -> {
      let assert Ok(children) = dict.get(rules, a)
      let new_traversed = insert(traversed, a, children)
      sort_impl(rules, rest, new_traversed)
    }
  }
}

fn insert(traversed: List(Int), a: Int, children: Dict(Int, Bool)) {
  let #(before, after) = list.split_while(traversed, fn(t) {
    case dict.get(children, t) {
      Ok(_) -> False
      Error(_) -> True
    }
  })
  list.flatten([before, [a], after])
}

pub fn main() {
  let #(rules, pages) =
    utils.input(debug(), test_input(), "src/day05.input")
    |> parse

  prepare(#(rules, pages))
  // |> part1
  |> part2(rules)
  |> io.debug
}
