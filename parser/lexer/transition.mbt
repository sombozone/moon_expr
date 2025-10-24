pub(all) enum State {
  Base        // 基础状态
  Number      //数字
  Identifier  //变量名 函数名 
  Operator    //运算符
  String      //引号包裹的字符串
  Bracket     //括号
  EOF         // 结束符
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

// 关键：让包装器实现 Transition，通过分派到内部具体类型
pub fn Lexer::get_transition(self: Lexer) -> &Transition raise LexerTransitionError {
    match self.state {
      Base => BaseTransition::{} as &Transition
      Number => NumberTransition::{} as &Transition
      _ => raise LexerTransitionError("Invalid transition wrapper")
    }
}

///|
/// Base transition - decides which specialized transition to use
pub struct BaseTransition {} derive(Show ,Eq)

pub fn BaseTransition::new() -> BaseTransition {
  BaseTransition::{}
}

impl Transition for BaseTransition with execute(self : BaseTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
    // let c = lexer.next_char()
    // match c {
    //   None => raise LexerTransitionError("Unexpected end of input")
    //   Some(c) => {
    //     if c.is_digit(10) {
    //       lexer.transition = State::Number
    //     } else if is_alphabetic(c) {
    //       lexer.transition = State::Identifier
    //     } else if c.is_whitespace() {
    //       lexer.commit()
    //       lexer.transition = State::Base
    //     } else if c == '"' {
    //       lexer.transition = State::String
    //     } else {
    //       lexer.transition = State::Operator
    //     }
    //   }
    // } 
    println("BaseTransition::execute")
  }

///|
pub struct NumberTransition {} derive(Show ,Eq)

pub fn NumberTransition::new() -> NumberTransition {
  NumberTransition::{}
}

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