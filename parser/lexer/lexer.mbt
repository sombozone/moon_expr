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
    raise Failure(
      "Invalid location: start position cannot be greater than end position",
    )
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
  Token::{ location: Location::{ from: 0, to: 0 }, kind: Kind::EOF, value: "" }
}

///|
/// 词元的位置和占位数量
pub struct Position {
  pos : Int
  index : Int
  bytes : Int
} derive(Show)
///|
/// Get the string position.
pub fn Position::pos(self : Position) -> Int {
  self.pos
}

///|
/// Get the index position.
pub fn Position::index(self : Position) -> Int {
  self.index
}

///|
/// Get the bytes position.
pub fn Position::bytes(self : Position) -> Int {
  self.bytes
}

///|
struct Lexer {
  source : String
  tokens : @queue.Queue[Token]
  transition : Base
  err : Error?
  mut start : Position
  mut current : Position
  mut eof : Bool
} derive(Show)

///|
pub fn Lexer::new(source~ : String) -> Self {
  Lexer::{
    source,
    tokens: @queue.new(),
    transition : Base::{},
    err: None,
    start: Position::{ pos: 0, index: 0, bytes: 0 },
    current: Position::{ pos: 0, index: 0, bytes: 0 },
    eof: false,
  }
}

pub fn Lexer::tokenize(self : Lexer) -> Array[Token] {
  for {
		let token = self.transition.step(self)
		match token {
			Some(t) => {
				self.tokens.push(t)
			}
			None => {
				break
			}
		}
	}
  let arr:Array[Token] = []
  self.tokens.each(t => {
    arr.push(t)
  })
  arr
}

pub fn Lexer::get_word(self : Lexer) -> StringView raise Error {
  println("get_word : \{self.start.index} \{self.current.index}") 
  self.source.to_string_view()[self.start.index:self.current.index]
}

///|
/// Get the current position of the lexer.
pub fn Lexer::current(self : Lexer) -> Position {
  self.current
}

///|
/// Check if the lexer has reached the end of file.
pub fn Lexer::eof(self : Lexer) -> Bool {
  self.eof
}

///|
/// Get the next char from the lexer.
pub fn Lexer::next(self : Lexer) -> Char? {
  if self.eof {
    println("idx : \{self.current.index} pos : \{self.current.pos}")
    return None
  }
  println("length : \{String::length(self.source)} \{self.source.iter().count()-1}")
  let len = self.source.iter().count()-1
  let mut index = self.current.index  
  // 获取当前字符
  match self.source.get_char(index) {
    Some(c) => {
      // 成功获取字符，更新位置
      let inc = @encoding/utf8.encode(c.to_string()).length()
      let bytes = self.current.bytes + inc
      let pos : Int = self.current.pos + 1
      index += 1
      self.current = Position::{ pos, index, bytes }
      println("currnt value : \{c}")
      if self.current.pos >= len {
        self.eof = true
        println("next eof :\{self.eof}")
      }
      Lexer::find_next(self)
      Some(c)
    }
    None => None
  }
}

pub fn Lexer::find_next(self : Lexer) -> Unit{
  let len = String::length(self.source)-1 
  let mut index = self.current.index
  if index >= len {
    self.eof = true
    return
  }
  match self.source.get_char(index) {
    None => {
      // 获取字符失败（可能是无效的UTF-8编码），跳过当前位置
      index += 1
      self.current = Position::{ pos:self.current.pos, index, bytes: self.current.bytes  }
      // 递归尝试下一个字符
      Lexer::find_next(self)
    }
    _ => println("next : \{self.current}")
  }
}

pub fn Lexer::backup(self : Lexer) -> Unit {
  if self.eof {
    self.eof = false
  }
  //向前查找字符
  let mut idx = self.current.index
  for{
    idx -= 1
    match self.source.get_char(idx) {
      Some(c) => {
        self.current = {pos:self.current.pos-1, index:idx, bytes:self.current.bytes-@encoding/utf8.encode(c.to_string()).length()}
        println("backup : \{self.current} val : \{c}")
        break
      }
      None => {
        continue
      }
    }
  }
}



pub fn Lexer::commit(self : Lexer) -> Unit {
  self.start = self.current
  println("commit : s->  \{self.start} e-> \{self.current}")
}
