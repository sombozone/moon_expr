///|
/// Transition states enum - represents the current state of the lexer
pub enum TransitionState {
  Base
  Number      //数字
  Identifier  //变量名 函数名 
  Operator    //运算符
  String      //引号包裹的字符串
  Bracket     //括号
  EOF
} derive(Show, Eq)

///|
/// Base transition trait that all transitions implement
pub trait Transition {
  step(self : Self, lexer : Lexer) -> TransitionState raise
}

///|
/// Base transition - decides which specialized transition to use
pub struct BaseTransition {} derive(Show)

///|
/// Number transition - handles numeric literals
pub struct NumberTransition {} derive(Show)

///|
/// Identifier transition - handles keywords and identifiers
pub struct IdentifierTransition {} derive(Show)

///|
/// String transition - handles string literals
pub struct StringTransition {} derive(Show)

///|
/// EOF transition - marks the end of file
pub struct EOFTransition {} derive(Show)

///|
/// Base transition implementation
/// Handles whitespace and delegates to specialized transitions
pub impl Transition for BaseTransition with step(
  self : BaseTransition,
  lexer : Lexer,
) -> TransitionState raise {
  if lexer.eof {
    return TransitionState::EOF
  }
  match lexer.next_char() {
    Some(c) =>
      // Handle whitespace - stay in base transition
      if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
        lexer.commit()
        TransitionState::Base
        // Handle digits - switch to number transition
      } else if c.is_ascii_digit() {
        lexer.rewind_back()
        TransitionState::Number
        // Handle letters and underscores - switch to identifier transition
      } else if c.is_ascii_alphabetic() || c == '_' {
        lexer.rewind_back()
        TransitionState::Identifier
        // Handle quotes - switch to string transition
      } else if c == '"' || c == '\'' {
        lexer.rewind_back()
        TransitionState::String
        // Handle other characters (operators, brackets, etc.)
      } else {
        // For now, stay in base transition for other characters
        // In a complete implementation, you might create OperatorTransition, etc.
        lexer.rewind_back()
        TransitionState::Base
      }
    None => TransitionState::EOF
  }
}

///|
/// Number transition implementation
/// Processes numeric literals
pub impl Transition for NumberTransition with step(
  self : NumberTransition,
  lexer : Lexer,
) -> TransitionState raise {
  if lexer.eof {
    // Create token for the number and return to base
    let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
    let token = Token::new(location= location, kind= Kind::Num, value= lexer.get_slice().to_string())
    lexer.tokens.push(token)
    lexer.commit()
    return TransitionState::Base
  }
  
  match lexer.next_char() {
    Some(c) => {
      if c.is_ascii_digit() {
        // Continue reading digits
        TransitionState::Number
      } else {
        // End of number - create token and return to base
        lexer.rewind_back()
        let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
        let token = Token::new(location= location, kind= Kind::Num, value= lexer.get_slice().to_string())
        lexer.tokens.push(token)
        lexer.commit()
        TransitionState::Base
      }
    }
    None => {
      // EOF reached - create token and return to base
      let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
      let token = Token::new(location= location, kind= Kind::Num, value= lexer.get_slice().to_string())
      lexer.tokens.push(token)
      lexer.commit()
      TransitionState::Base
    }
  }
}

///|
/// Identifier transition implementation
/// Processes keywords and identifiers
pub impl Transition for IdentifierTransition with step(
  self : IdentifierTransition,
  lexer : Lexer,
) -> TransitionState raise {
  if lexer.eof {
    // Create token for the identifier and return to base
    let value = lexer.get_slice().to_string()
    let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
    let token = Token::new(location= location, kind= Kind::Ident, value= value)
    lexer.tokens.push(token)
    lexer.commit()
    return TransitionState::Base
  }
  
  match lexer.next_char() {
    Some(c) => {
      if c.is_ascii_alphabetic() || c.is_ascii_digit() || c == '_' {
        // Continue reading identifier characters
        TransitionState::Identifier
      } else {
        // End of identifier - create token and return to base
        lexer.rewind_back()
        let value = lexer.get_slice().to_string()
        let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
        let token = Token::new(location= location, kind= Kind::Ident, value= value)
        lexer.tokens.push(token)
        lexer.commit()
        TransitionState::Base
      }
    }
    None => {
      // EOF reached - create token and return to base
      let value = lexer.get_slice().to_string()
      let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
      let token = Token::new(location= location, kind= Kind::Ident, value= value)
      lexer.tokens.push(token)
      lexer.commit()
      TransitionState::Base
    }
  }
}

///|
/// String transition implementation
/// Processes string literals
pub impl Transition for StringTransition with step(
  self : StringTransition,
  lexer : Lexer,
) -> TransitionState raise {
  if lexer.eof {
    // Unclosed string - handle error
    // For now, just create the token and return to base
    let value = lexer.get_slice().to_string()
    let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
    let token = Token::new(location= location, kind= Kind::Str, value= value)
    lexer.tokens.push(token)
    lexer.commit()
    return TransitionState::Base
  }
  
  match lexer.next_char() {
    Some(c) => {
      // Check for closing quote
      if c == '"' || c == '\'' {
        // End of string - create token and return to base
        let value = lexer.get_slice().to_string()
        let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
        let token = Token::new(location= location, kind= Kind::Str, value= value)
        lexer.tokens.push(token)
        lexer.commit()
        TransitionState::Base
      } else {
        // Continue reading string content
        TransitionState::String
      }
    }
    None => {
      // EOF reached - create token and return to base
      let value = lexer.get_slice().to_string()
      let location = Location::new(from= lexer.start.pos, to= lexer.current.pos)
      let token = Token::new(location= location, kind= Kind::Str, value= value)
      lexer.tokens.push(token)
      lexer.commit()
      TransitionState::Base
    }
  }
}

///|
/// EOF transition implementation
/// Marks the end of file
pub impl Transition for EOFTransition with step(
  self : EOFTransition,
  lexer : Lexer,
) -> TransitionState raise {
  // Create EOF token
  let location = Location::new(from= lexer.current.pos, to= lexer.current.pos)
  let token = Token::new(location= location, kind= Kind::EOF, value= "")
  lexer.tokens.push(token)
  lexer.commit()
  // Stay in EOF transition
  TransitionState::EOF
}