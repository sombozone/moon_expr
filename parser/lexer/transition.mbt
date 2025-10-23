trait Transition {
  step(self : Self, lexer : Lexer) -> Token?
}

struct Base {} derive(Show)

pub impl Transition for Base with step(self : Base, lexer : Lexer) -> Token? {
  if lexer.eof {
    return None
  }
  let t = lexer.next_char().unwrap()
  match t {
        _ => println("unexpected token: \{t}")
  }
  None
}
// struct Number {}
// pub impl Transition for Number with step(self, lexer:Lexer) {
  
// }

// struct Operator {}

// struct Identifer {}