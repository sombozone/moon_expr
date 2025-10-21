///|
enum Kind {
  Identifier
  Number
  String
  Operator
  Bracket
  EOF
} derive(Show)

///|
pub struct Location {
  from : Int
  to : Int
} derive(Show)

///|
/// Create a new Location with the given start and end positions.
/// This is the recommended way to create Location instances.
/// Validates that the range is valid (from <= to).
pub fn create_location(from~ : Int, to~ : Int) -> Location raise {
  if from > to {
    raise Failure("Invalid location: start position cannot be greater than end position")
  }
  Location::{ from, to }
}

///|
/// Get the start position of a Location.
pub fn Location::from(self : Location) -> Int {
  self.from
}

///|
/// Get the end position of a Location.
pub fn Location::to(self : Location) -> Int {
  self.to
}

///|
struct Token {
  location : Location
  kind : Kind
  value : String
} derive(Show)

struct Lexer{
    source : String
    tokens : @queue.Queue[Token]
    err : Error
    start : Int
    end : Int
    eof : Bool
} derive(Show)

