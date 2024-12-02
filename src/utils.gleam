import gleam/int

pub fn to_int(string: String) -> Int {
  let assert Ok(number) = int.parse(string)
  number
}
