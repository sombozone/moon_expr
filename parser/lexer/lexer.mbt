///|
enum Kind {
  Ident
  Num
  Str
  Oper
  Bracket
  EOF
} derive(Show)



///|
struct Location {
  from : Int
  to : Int
} derive(Show)

///|
/// Create a new Location with the given start and end positions.
/// This is the recommended way to create Location instances.
/// Validates that the range is valid (from <= to).
pub fn Location::new(from~ : Int, to~ : Int) -> Location raise {
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

///|
/// Create a new Token with the given location, kind, and value.
pub fn Token::new(location~ : Location, kind~ : Kind, value~ : String) -> Token {
  Token::{ location, kind, value }
}

///|
/// Create an empty Token with default values.
/// Uses EOF kind, empty string value, and location from 0 to 0.
pub fn Token::new_empty() -> Token {
  Token::{
    location: Location::{ from: 0, to: 0 },
    kind: Kind::EOF,
    value: ""
  }
}

struct Lexer{
    source : String
    tokens : @queue.Queue[Token]
    err : Option[Error]
    start : Int
    end : Int
    eof : Bool
} derive(Show)

pub fn Lexer::new(source~ : String) -> Lexer {
    Lexer::{
        source,
        tokens : @queue.new(),
        err : None,
        start : 0,
        end : 0,
        eof : false
    }
}


///|
/// Get the next char from the lexer.
fn Lexer::next(self : Lexer) -> Char {
    if self.end >= String::length(self.source) {
        self.eof = true
        
    }
}
func (l *Lexer) next() rune {
	if l.end.byte >= len(l.source.String()) {
		l.eof = true
		return eof
	}
	r, sz := utf8.DecodeRuneInString(l.source.String()[l.end.byte:])
	l.end.rune++
	l.end.byte += sz
	return r
}