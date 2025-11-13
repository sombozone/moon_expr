///|
/// 获取当前状态对应的 Transition（公开给测试与外部调用）
const LEXER_DEBUG : Bool = false

fn trace(msg : String) -> Unit {
  if LEXER_DEBUG { println(msg) }
}
pub(all) enum Kind {
  Ident
  Num
  Str
  Oper
  Bracket
  EOF
} derive(Show,Eq)

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
pub(all) struct Token {
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
  mut tokens : Array[Token]
  mut state : State
  err : Error?
  mut start : Position
  mut current : Position
  mut eof : Bool
} derive(Show)

///|
pub fn Lexer::new(source~ : String) -> Self {
  Lexer::{
    source,
    tokens: [],
    state: State::Base,
    err: None,
    start: Position::{ pos: 0, index: 0, bytes: 0 },
    current: Position::{ pos: 0, index: 0, bytes: 0 },
    eof: false,
  }
}

pub fn Lexer::tokens(self : Lexer) -> Array[Token] {
  self.tokens
}

pub fn Lexer::set_state(self : Lexer, state: State) -> Unit {
  self.state = state
}
pub fn Lexer::state(self : Lexer) -> State  {
  self.state
}

///|
/// Get the current position of the lexer.
pub fn Lexer::current(self : Lexer) -> Position {
  self.current
}

///|
/// Check if the lexer has reached the end of file.
pub fn Lexer::eof(self : Lexer) -> Bool {
  // 统一 EOF 判定：基于 current.index 与 source 的长度进行实时计算
  let len = String::length(self.source)
  let at_end = self.current.index >= len
  // 同步内部字段，保持一致性（也兼容已有代码在推进/回退时直接设置 eof 的行为）
  if at_end != self.eof {
    self.eof = at_end
  }
  at_end
}

// ///|
// /// Execute a transition step based on the current transition state
// fn Lexer::execute_transition_step(self : Lexer) -> TransitionState raise {
//   match self.transition {
//     TransitionState::Base => Transition::step(BaseTransition::{  }, self)
//     TransitionState::Number => Transition::step(NumberTransition::{  }, self)
//     TransitionState::Identifier =>
//     Transition::step(IdentifierTransition::{  }, self)
//     TransitionState::String => Transition::step(StringTransition::{  }, self)
//     TransitionState::EOF => Transition::step(EOFTransition::{  }, self)
//     _ => TransitionState::Base
//   }
// }

///|
/// Tokenize the source string.
pub fn Lexer::tokenize(self : Lexer) -> Array[Token] raise LexerTransitionError {
  // Process tokens until we reach EOF
  while self.state != State::EOF {
    // Execute the current transition step
    // self.transition = self.execute_transition_step()
    let transition = Lexer::get_transition(self)
    transition.execute(self)

  }

  // Convert queue to array
  let arr : Array[Token] = []
  self.tokens.each(t => arr.push(t))
  arr
}

///|
/// Get the current slice of the lexer.
pub fn Lexer::get_slice(self : Lexer) -> StringView raise Error {
  trace("get_slice : \{self.start.index} \{self.current.index}")
  self.source.to_string_view()[self.start.index:self.current.index]
}

///|
/// Get the next char from the lexer.
pub fn Lexer::next_char(self : Lexer) -> Char? {
  if Lexer::eof(self) {
    trace("idx : \{self.current.index} pos : \{self.current.pos}")
    return None
  }
  trace(
    "length : \{String::length(self.source)} \{self.source.iter().count()}",
  )
  let len = self.source.iter().count()
  if len == 0 {
    // 统一通过 Lexer::eof(self) 同步 EOF 状态，不直接赋值
    ignore(Lexer::eof(self))
    return None
  }
  let index = self.current.index
  // 获取当前字符
  match self.source.get_char(index) {
    Some(c) => {
      // 成功获取字符，更新位置
      let inc = @encoding/utf8.encode(c.to_string()).length()
      let bytes = self.current.bytes + inc
      let pos : Int = self.current.pos + 1
      self.current = Position::{ pos, index, bytes }
      trace("currnt value : \{c} \n begin: \{self.current}")
      Lexer::update_next_position(self)
      trace("find_next end for \{c}")
      Some(c)
    }
    None => None
  }
}

///|
pub fn Lexer::update_next_position(self : Lexer) -> Unit {
  let len = String::length(self.source)
  let index = self.current.index + 1
  if index >= len {
    self.current = Position::{
      pos: self.current.pos,
      index: len,
      bytes: self.current.bytes,
    }
    // 统一通过 Lexer::eof(self) 同步 EOF 状态，不直接赋值
    ignore(Lexer::eof(self))
    trace("eof :\{self.eof} \{self.current}")
    return
  }
  trace(Show::to_string(self.source.get_char(index)))
  match self.source.get_char(index) {
    None => {
      // 获取字符失败（可能是无效的UTF-8编码），跳过当前位置
      self.current = Position::{
        pos: self.current.pos,
        index,
        bytes: self.current.bytes,
      }
      // 递归尝试下一个字符
      Lexer::update_next_position(self)
    }
    Some(c) => {
      trace("next c : \{c} \{c.utf16_len()} \{String::length(c.to_string())}")
      // emoji变体选择符
      if is_emoji_selector(c) {
        // 跳过空白字符
        self.current = Position::{
          pos: self.current.pos,
          index,
          bytes: self.current.bytes,
        }
        trace("skip")
        Lexer::update_next_position(self)
      } else {
        self.current = Position::{
          pos: self.current.pos,
          index,
          bytes: self.current.bytes,
        }
        trace("next :  \{c} \{self.current} ")
        return
      }
    }
  }
}

///|
pub fn Lexer::peek_current(self : Lexer) -> StringView raise Error {
  let next_pos = Lexer::find_next_position(self, self.current)
  let view = self.source.to_string_view()
  view[self.current.index:next_pos.index]
}

///|
pub fn Lexer::find_next_position(self : Lexer, from : Position) -> Position {
  let len = String::length(self.source)
  let tt = self.source.iter().count()
  let index = from.index + 1
  if index >= len {
    return Position::{ pos: tt, index: len, bytes: 0 }
  }
  match self.source.get_char(index) {
    None =>
      // 递归尝试下一个字符
      Lexer::find_next_position(self, Position::{
        pos: from.pos,
        index,
        bytes: 0,
      })
    Some(c) => {
      trace("next c : \{c} \{c.utf16_len()} \{String::length(c.to_string())}")
      // emoji变体选择符
      if is_emoji_selector(c) {
        // 跳过空白字符
        trace("skip")
        Lexer::find_next_position(self, Position::{
          pos: from.pos,
          index,
          bytes: 0,
        })
      } else {
        let pos = Position::{ pos: from.pos + 1, index, bytes: 0 }
        trace("next :  \{c} \{pos} ")
        return pos
      }
    }
  }
}

///|
pub fn Lexer::rewind_back(self : Lexer) -> Unit {
  // 回退后通过统一接口重新计算 EOF
  // 不直接修改 self.eof
  ignore(Lexer::eof(self))
  //向前查找字符
  let mut idx = self.current.index
  for {
    idx -= 1
    match self.source.get_char(idx) {
      Some(c) => {
        if is_emoji_selector(c) {
          continue
        }
        self.current = {
          pos: self.current.pos - 1,
          index: idx,
          bytes: self.current.bytes -
          @encoding/utf8.encode(c.to_string()).length(),
        }
        trace("backup : \{self.current} val : \{c}")
        break
      }
      None => continue
    }
  }
  // 再次统一 EOF 状态，避免外部直接依赖字段
  ignore(Lexer::eof(self))
}

///|
pub fn Lexer::commit(self : Lexer) -> Unit {
  self.start = self.current
  trace("commit : s->  \{self.start} e-> \{self.current}")
}

pub fn Lexer::recover(self : Lexer) -> Unit {
  self.current = self.start
  trace("recover : s->  \{self.start} e-> \{self.current}")
}

fn Lexer::push_token(self : Lexer, kind: Kind) -> Unit {
  // 使用从 start 到 current 的切片作为 token 文本
  let res = try? self.get_slice().to_string()
  trace("push token : \{kind} \{res} \{self}")
  match res {
    Ok(v) => {
      self.tokens.push(Token::{
        location: Location::{ from: self.start.index, to: self.current.index },
        kind,
        value: v,
      })
      self.commit()
    }
    Err(_) => trace("emit error")
  }
}

/// Accessors for Token fields to avoid abstract-type field access issues
pub fn Token::kind(self : Token) -> Kind { self.kind }
pub fn Token::value(self : Token) -> String { self.value }
pub fn Token::location(self : Token) -> Location { self.location }
///|
