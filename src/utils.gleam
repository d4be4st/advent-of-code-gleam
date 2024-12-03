import simplifile
import gleam/int

pub fn to_int(string: String) -> Int {
  let assert Ok(number) = int.parse(string)
  number
}

pub fn input(debug: Bool, test_input: String, path: String) -> String {
  case debug {
    True -> test_input
    False -> {
      let assert Ok(input) = simplifile.read(path)
      input
    }
  }
}
