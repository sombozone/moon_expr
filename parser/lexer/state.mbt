trait State {
  next(Lexer) -> State
}

struct Root {}
// pub impl State for Root with next(self, lexer) {
//   match
// }
struct Number {}
// pub impl State for Number with next(self, lexer) {
  
// }

struct Operator {}

struct Identifer {}