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
fn Lexer::get_transition(self: Lexer) -> &Transition raise LexerTransitionError {
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

impl Transition for BaseTransition with execute(_self : BaseTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
    if lexer.eof {
      lexer.state = State::EOF
      return
    }
    let _ = match lexer.next_char() {
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
        } else if c == '.' {
          // 处理以点开头的小数：例如 .5
          let pv = try? Lexer::peek_current(lexer).to_string()
          let _ = match pv {
            Ok(s) => {
              let _ = match s.get_char(0) {
                Some(ch) => {
                  // 下一个是数字或下划线：交由 NumberTransition 去统一校验
                  if (ch >= '0' && ch <= '9') || ch == '_' {
                    lexer.state = State::Number
                  } else {
                    lexer.rewind_back()
                    lexer.state = State::Operator
                  }
                }
                None => {
                  lexer.rewind_back()
                  lexer.state = State::Operator
                }
              }
            }
            Err(_) => {
              lexer.rewind_back()
              lexer.state = State::Operator
            }
          }
        } else if (c.to_string().contains_any(chars="()[]{}")) {
          // 将指针回退到括号字符开始处，由 BracketTransition 读取并产生 token
          lexer.rewind_back()
          lexer.state = State::Bracket
        } else if c == '"' {
          lexer.rewind_back()
          lexer.state = State::String
        } else if is_alphabetic(c) || c == '_' || c == '$' {
          lexer.rewind_back()
          lexer.state = State::Identifier
        } else {
          lexer.rewind_back()
          lexer.state = State::Operator
        }
      }
    } 
    println("BaseTransition::execute")
  }

///|
pub struct NumberTransition {} derive(Show ,Eq)

impl Transition for NumberTransition with execute(_self : NumberTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  // 清空并按“步骤1：整数部分（不同进制）”实现
  println("NumberTransition::execute")
  // 回退到数字起点，由本状态完整读取数字
  lexer.rewind_back()
  lexer.commit()

  let mut base : Int = 10
  let mut started_with_dot : Bool = false

  // 读取首字符；若为 '0'，尝试进制前缀；否则视作十进制起始
  match Lexer::next_char(lexer) {
    None => {
      // 读取失败并不必然表示 EOF（例如遇到变体选择符或无效编码返回 None）。
      // 仅在确认为 EOF 时才发出 EOF，否则回退到 Base 让其决定下一步。
      if Lexer::eof(lexer) {
        lexer.push_token(Kind::EOF)
        lexer.state = State::EOF
      } else {
        lexer.state = State::Base
      }
      return
    }
    Some('.') => {
      // 以点开头的小数：.5 等，仅支持十进制
      base = 10
      started_with_dot = true
      // 小数部分必须至少包含一个数字
      let mut has_frac_digit = false
      let mut prev_underscore = false
      for {
        let pvf = try? Lexer::peek_current(lexer).to_string()
        let mut consumed : Bool = false
        match pvf {
          Ok(sf) => {
            match sf.get_char(0) {
              Some('_') => {
                // 禁止段首或连续下划线
                if !has_frac_digit || prev_underscore { raise LexerTransitionError("invalid underscore placement in fraction") }
                let _ = Lexer::next_char(lexer); consumed = true; prev_underscore = true
              }
              Some(ch) => {
                if ch >= '0' && ch <= '9' {
                  let _ = Lexer::next_char(lexer)
                  has_frac_digit = true
                  prev_underscore = false
                  consumed = true
                }
              }
              None => ()
            }
          }
          Err(_) => ()
        }
        if !consumed { break }
      }
      if !has_frac_digit { raise LexerTransitionError("invalid decimal fraction: missing digits after '.'") }
      if prev_underscore { raise LexerTransitionError("invalid underscore at end of fraction") }
    }
    Some('0') => {
      let pv = try? Lexer::peek_current(lexer).to_string()
      match pv {
        Ok(s) => {
          match s.get_char(0) {
            // 0x / 0X -> 十六进制
            Some('x') | Some('X') => {
              let _ = Lexer::next_char(lexer)
              base = 16
              let mut has_any = false
              let mut prev_underscore = false
              for {
                let pv2 = try? Lexer::peek_current(lexer).to_string()
                let ch_opt = match pv2 {
                  Ok(ss) => ss.get_char(0)
                  Err(_) => None
                }
                let mut consumed : Bool = false
                match ch_opt {
                  Some('_') => {
                    if !has_any || prev_underscore { raise LexerTransitionError("invalid underscore placement in hex literal") }
                    let _ = Lexer::next_char(lexer); consumed = true; prev_underscore = true
                  }
                  Some(ch) => {
                    if (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') {
                      let _ = Lexer::next_char(lexer)
                      has_any = true
                      prev_underscore = false
                      consumed = true
                    }
                  }
                  None => ()
                }
                if !consumed { break }
              }
              if !has_any { raise LexerTransitionError("invalid hex literal: missing digits after 0x/0X") }
              if prev_underscore { raise LexerTransitionError("invalid underscore at end of hex literal") }
            }
            // 0o / 0O -> 八进制
            Some('o') | Some('O') => {
              let _ = Lexer::next_char(lexer)
              base = 8
              let mut has_any = false
              let mut prev_underscore = false
              for {
                let pv2 = try? Lexer::peek_current(lexer).to_string()
                let ch_opt = match pv2 {
                  Ok(ss) => ss.get_char(0)
                  Err(_) => None
                }
                let mut consumed : Bool = false
                match ch_opt {
                  Some('_') => {
                    if !has_any || prev_underscore { raise LexerTransitionError("invalid underscore placement in octal literal") }
                    let _ = Lexer::next_char(lexer); consumed = true; prev_underscore = true
                  }
                  Some(ch) => {
                    if ch >= '0' && ch <= '7' {
                      let _ = Lexer::next_char(lexer)
                      has_any = true
                      prev_underscore = false
                      consumed = true
                    } else if ch >= '8' && ch <= '9' {
                      raise LexerTransitionError("invalid octal digit")
                    }
                  }
                  None => ()
                }
                if !consumed { break }
              }
              if !has_any { raise LexerTransitionError("invalid octal literal: missing digits after 0o/0O") }
              if prev_underscore { raise LexerTransitionError("invalid underscore at end of octal literal") }
            }
            // 0b / 0B -> 二进制
            Some('b') | Some('B') => {
              let _ = Lexer::next_char(lexer)
              base = 2
              let mut has_any = false
              let mut prev_underscore = false
              for {
                let pv2 = try? Lexer::peek_current(lexer).to_string()
                let ch_opt = match pv2 {
                  Ok(ss) => ss.get_char(0)
                  Err(_) => None
                }
                let mut consumed : Bool = false
                match ch_opt {
                  Some('_') => {
                    if !has_any || prev_underscore { raise LexerTransitionError("invalid underscore placement in binary literal") }
                    let _ = Lexer::next_char(lexer); consumed = true; prev_underscore = true
                  }
                  Some('0') | Some('1') => {
                    let _ = Lexer::next_char(lexer)
                    has_any = true
                    prev_underscore = false
                    consumed = true
                  }
                  Some(ch) => {
                    if (ch >= '0' && ch <= '9') || is_alphabetic(ch) {
                      raise LexerTransitionError("invalid binary digit")
                    }
                  }
                  None => ()
                }
                if !consumed { break }
              }
              if !has_any { raise LexerTransitionError("invalid binary literal: missing digits after 0b/0B") }
              if prev_underscore { raise LexerTransitionError("invalid underscore at end of binary literal") }
            }
            // 无前缀：十进制（以 0 开头）
            _ => { base = 10 }
          }
        }
        Err(_) => ()
      }
    }
    // 非零数字：走十进制路径
    Some(_) => ()
  }

  // 十进制余下的整数位（允许下划线，但禁止段首/结尾/连续下划线）
  if base == 10 && !started_with_dot {
    let mut int_prev_underscore : Bool = false
    let mut int_has_any : Bool = true // 首个数字已在上面被消费
    for {
      let pv = try? Lexer::peek_current(lexer).to_string()
      let mut consumed : Bool = false
      match pv {
        Ok(s) => {
          match s.get_char(0) {
            Some('_') => {
              if !int_has_any || int_prev_underscore { raise LexerTransitionError("invalid underscore placement in integer literal") }
              let _ = Lexer::next_char(lexer); consumed = true; int_prev_underscore = true
            }
            Some(ch) => {
              if ch >= '0' && ch <= '9' {
                let _ = Lexer::next_char(lexer)
                int_has_any = true
                int_prev_underscore = false
                consumed = true
              }
            }
            None => ()
          }
        }
        Err(_) => ()
      }
      if !consumed { break }
    }
    if int_prev_underscore { raise LexerTransitionError("invalid underscore at end of integer literal") }
  }

  // 步骤2：十进制的小数部分（如果尚未以点开头）
  let mut saw_fraction : Bool = started_with_dot
  if base == 10 && !started_with_dot {
    let pv_dot = try? Lexer::peek_current(lexer).to_string()
    match pv_dot {
      Ok(s) => {
        match s.get_char(0) {
          Some('.') => {
            let _ = Lexer::next_char(lexer) // consume '.'
            let mut has_frac_digit = false
            let mut prev_underscore = false
            for {
              let pvf = try? Lexer::peek_current(lexer).to_string()
              let mut consumed : Bool = false
              match pvf {
                Ok(sf) => {
                  match sf.get_char(0) {
                    Some('_') => {
                      // 禁止段首或连续下划线
                      if !has_frac_digit || prev_underscore { raise LexerTransitionError("invalid underscore placement in fraction") }
                      let _ = Lexer::next_char(lexer); consumed = true; prev_underscore = true
                    }
                    Some(ch) => {
                      if ch >= '0' && ch <= '9' {
                        let _ = Lexer::next_char(lexer)
                        has_frac_digit = true
                        prev_underscore = false
                        consumed = true
                      }
                    }
                    None => ()
                  }
                }
                Err(_) => ()
              }
              if !consumed { break }
            }
            if !has_frac_digit { raise LexerTransitionError("invalid decimal fraction: missing digits after '.'") }
            if prev_underscore { raise LexerTransitionError("invalid underscore at end of fraction") }
            saw_fraction = true
          }
          _ => ()
        }
      }
      Err(_) => ()
    }
  }

  // 步骤3：十进制的指数部分（e/E + 可选 +/- + 至少一位数字，允许下划线）
  if base == 10 {
    let pv_exp = try? Lexer::peek_current(lexer).to_string()
    match pv_exp {
      Ok(se) => {
        match se.get_char(0) {
          Some('e') | Some('E') => {
            let _ = Lexer::next_char(lexer) // consume e/E
            // 可选符号
            let pv_sign = try? Lexer::peek_current(lexer).to_string()
            match pv_sign {
              Ok(ss) => {
                match ss.get_char(0) {
                  Some('+') | Some('-') => { let _ = Lexer::next_char(lexer) }
                  _ => ()
                }
              }
              Err(_) => ()
            }
            // 至少一位数字，允许下划线
            let mut has_exp_digit = false
            let mut prev_underscore = false
            for {
              let pve = try? Lexer::peek_current(lexer).to_string()
              let mut consumed : Bool = false
              match pve {
                Ok(se2) => {
                  match se2.get_char(0) {
                    Some('_') => {
                      if !has_exp_digit || prev_underscore { raise LexerTransitionError("invalid underscore placement in exponent") }
                      let _ = Lexer::next_char(lexer); consumed = true; prev_underscore = true
                    }
                    Some(ch) => {
                      if ch >= '0' && ch <= '9' {
                        let _ = Lexer::next_char(lexer)
                        has_exp_digit = true
                        prev_underscore = false
                        consumed = true
                      }
                    }
                    None => ()
                  }
                }
                Err(_) => ()
              }
              if !consumed { break }
            }
            if !has_exp_digit { raise LexerTransitionError("invalid exponent: missing digits after e/E") }
            if prev_underscore { raise LexerTransitionError("invalid underscore at end of exponent") }
          }
          _ => ()
        }
      }
      Err(_) => ()
    }
  }

  // 粘连错误：数字后直接跟标识符字符（字母、数字、'_'、'$'）
  let pv_tail = try? Lexer::peek_current(lexer).to_string()
  match pv_tail {
    Ok(st) => {
      match st.get_char(0) {
        Some(ch) => {
          if is_alpha_numeric(ch) || ch == '$' {
            raise LexerTransitionError("numeric literal glued to identifier")
          }
        }
        None => ()
      }
    }
    Err(_) => ()
  }

  // 发出数字 token，返回 Base
  lexer.push_token(Kind::Num)
  lexer.state = State::Base
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

impl Transition for IdentifierTransition with execute(_self : IdentifierTransition, _lexer : Lexer) -> Unit raise LexerTransitionError {
  println("IdentifierTransition::execute")
  let lexer = _lexer
  lexer.commit()
  match Lexer::next_char(lexer) {
    None => {
      if Lexer::eof(lexer) {
        lexer.push_token(Kind::EOF)
        lexer.state = State::EOF
      } else {
        lexer.state = State::Base
      }
      return
    }
    Some(ch) => {
      if !(is_alphabetic(ch) || ch == '_' || ch == '$') {
        raise LexerTransitionError("invalid identifier start")
      }
    }
  }
  for {
    let pv = try? Lexer::peek_current(lexer).to_string()
    let mut consumed : Bool = false
    match pv {
      Ok(s) => {
        match s.get_char(0) {
          Some(ch) => {
            if is_alpha_numeric(ch) || ch == '_' || ch == '$' {
              let _ = Lexer::next_char(lexer)
              consumed = true
            }
          }
          None => ()
        }
      }
      Err(_) => ()
    }
    if !consumed { break }
  }
  lexer.push_token(Kind::Ident)
  lexer.state = State::Base
}

///|
/// 
/// 
pub struct OperatorTransition {} derive(Show ,Eq)

impl Transition for OperatorTransition with execute(_self : OperatorTransition, _lexer : Lexer) -> Unit raise LexerTransitionError {
  println("OperatorTransition::execute")
  let lexer = _lexer
  lexer.commit()
  let mut has_any : Bool = false
  for {
    let pv = try? Lexer::peek_current(lexer).to_string()
    let mut consumed : Bool = false
    match pv {
      Ok(s) => {
        match s.get_char(0) {
          Some(ch) => {
            let is_br = ch.to_string().contains_any(chars="()[]{}")
            if !ch.is_whitespace() && !(is_alpha_numeric(ch) || ch == '_' || ch == '$') && !is_br && ch != '"' {
              let _ = Lexer::next_char(lexer)
              has_any = true
              consumed = true
            }
          }
          None => ()
        }
      }
      Err(_) => ()
    }
    if !consumed { break }
  }
  if !has_any {
    if Lexer::eof(lexer) {
      lexer.push_token(Kind::EOF)
      lexer.state = State::EOF
    } else {
      lexer.state = State::Base
    }
    return
  }
  lexer.push_token(Kind::Oper)
  lexer.state = State::Base
}

pub struct StringTransition {} derive(Show ,Eq)

impl Transition for StringTransition with execute(_self : StringTransition, _lexer : Lexer) -> Unit raise LexerTransitionError {
  println("StringTransition::execute")
  let lexer = _lexer
  lexer.commit()
  match Lexer::next_char(lexer) {
    Some('"') => ()
    Some(_) => { raise LexerTransitionError("invalid string start") }
    None => {
      if Lexer::eof(lexer) {
        lexer.push_token(Kind::EOF)
        lexer.state = State::EOF
      } else {
        lexer.state = State::Base
      }
      return
    }
  }
  let mut escaped : Bool = false
  let mut terminated : Bool = false
  for {
    match Lexer::next_char(lexer) {
      None => { break }
      Some(ch) => {
        if escaped {
          escaped = false
        } else {
          if ch == '\\' {
            escaped = true
          } else if ch == '"' {
            terminated = true
            break
          }
        }
      }
    }
  }
  if !terminated { raise LexerTransitionError("unterminated string literal") }
  lexer.push_token(Kind::Str)
  lexer.state = State::Base
}

pub struct BracketTransition {} derive(Show ,Eq)

impl Transition for BracketTransition with execute(_self : BracketTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  println("BracketTransition::execute")
  // 读取一个括号字符并推送 token，位置为该字符的索引范围
  match lexer.next_char() {
    Some(_) => {
      lexer.push_token(Kind::Bracket)
      lexer.state = State::Base
    }
    None => {
      // 输入耗尽则推 EOF
      lexer.push_token(Kind::EOF)
      lexer.state = State::EOF
    }
  }
}

pub struct EOFTransition {} derive(Show ,Eq)

impl Transition for EOFTransition with execute(_self : EOFTransition, lexer : Lexer) -> Unit raise LexerTransitionError {
  println("EOFTransition::execute")
  lexer.push_token(Kind::EOF)
}
