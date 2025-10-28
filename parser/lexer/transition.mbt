///|
/// Lexer state machine for tokenization.
/// Defines the high-level scanning states used by the lexer.
/// - Base: Default scanning state; decides which specialized transition to use.
/// - Number: Reading numeric literals (integers, decimals, etc.).
/// - Identifier: Reading identifiers (variable and function names).
/// - Operator: Reading operators and punctuation symbols.
/// - String: Reading double-quoted string literals.
/// - Bracket: Reading bracket tokens such as (), [], {}.
/// - EOF: End-of-file sentinel state; terminates tokenization.
pub(all) enum State {
  Base
  Number
  Identifier
  Operator
  String
  Bracket
  EOF
} derive(Show,Eq)

///|
/// Transition trait
/// Provides state routing and contextual preparation for the lexer.
///
/// - `execute`: computes the next State based on current lexer input.
pub(open) trait Transition {
  /// Compute the next State from the current lexer input.
  /// May raise if input is invalid or cannot be processed.
  execute(self : Self, lexer : Lexer) -> Unit raise LexerTransitionError
}

suberror LexerTransitionError String

// let the wrapper implement Transition by dispatching to inner concrete types
pub fn Lexer::get_transition(self: Lexer) -> &Transition raise LexerTransitionError {
    if self.eof {
      self.state = State::EOF
    }
    match self.state {
      Base => BaseTransition::{} as &Transition
      Number => NumberTransition::{} as &Transition
      Identifier => IdentifierTransition::{} as &Transition
      Operator => OperatorTransition::{} as &Transition
      String => StringTransition::{} as &Transition
      Bracket => BracketTransition::{} as &Transition
      EOF => EOFTransition::{} as &Transition
      _ => raise LexerTransitionError("Invalid transition wrapper")
    }
}

///|
/// Base transition - decides which specialized transition to use
pub struct BaseTransition {} derive(Show ,Eq)

impl Transition for BaseTransition with execute(self : BaseTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
    if lexer.eof {
      lexer.state = State::EOF
      return
    }
    match lexer.next_char() {
      None => {
        println("BaseTransition::execute None")
        lexer.eof = true
      } 
      Some(c) => {
        if c.is_whitespace() {
          lexer.commit() //skip whitespace
          lexer.state = State::Base
        } else if c.is_digit(10) {
          lexer.state = State::Number
        }else if("()[]{}".contains_any(chars=c.to_string().to_string_view())){
          lexer.rewind_back()
          lexer.state = State::Bracket
        }
      }
    } 
    println("BaseTransition::execute")
  }

///|
pub struct NumberTransition {} derive(Show ,Eq)

impl Transition for NumberTransition with execute(self : NumberTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  // match lexer.next_char() {
  //   Some(c) => {
  //     lexer.rewind_back()
  //     if c.is_ascii_digit() {
  //       lexer.transition = State::Number
  //     } else {
  //       lexer.transition = State::Operator
    //     }
  //   }
  //   None => lexer.transition = State::EOF
  // }
  println("NumberTransition::execute")
}

///|
/// 读取数字序列，遇到停止符号结束
/// 停止符包括空格 、运算符、括号、EOF
/// 处理二进制（0b）、八进制（0o）、十进制、十六进制（0x）
/// 处理小数 0.5、 .5
/// 处理科学计数法 1e10、 1.0e-10
pub fn NumberTransition::scan_number()->Unit  {

}

///|
/// Identifier transition - reads identifiers (variable and function names)
pub struct IdentifierTransition {} derive(Show ,Eq)

pub fn IdentifierTransition::new() -> IdentifierTransition {
  IdentifierTransition::{}
}

impl Transition for IdentifierTransition with execute(self : IdentifierTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  
  println("IdentifierTransition::execute")
}

///|
/// 
/// 
pub struct OperatorTransition {} derive(Show ,Eq)

impl Transition for OperatorTransition with execute(self : OperatorTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  println("OperatorTransition::execute")
}

pub struct StringTransition {} derive(Show ,Eq)

impl Transition for StringTransition with execute(self : StringTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  println("StringTransition::execute")
}

pub struct BracketTransition {} derive(Show ,Eq)

impl Transition for BracketTransition with execute(self : BracketTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  println("BracketTransition::execute")
  let _ = lexer.next_char()
  lexer.state = State::Base
  lexer.push_token(Kind::Bracket)
}

pub struct EOFTransition {} derive(Show ,Eq)

impl Transition for EOFTransition with execute(self : EOFTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  println("EOFTransition::execute")
  lexer.push_token(Kind::EOF)
}
