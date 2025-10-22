// trait Transition {
//   step(lexer:Lexer) -> Unit
// }

struct Base {} derive(Show)

// pub(all)  impl Transition for Base with step(self, lexer:Lexer) {
//   // match lexer.next() {
//   //   Some(t) => {
//   //     match t.unwrap() {
//   //       util.is_space(t) => {
//   //         // skip whitespace 
//   //         lexer.commit()
//   //       }
//   //       // util.is_digit(t) => {
//   //       //  // lexer.transition = Number::{}
//   //       // }
//   //       _=> println("unexpected token: \{t}")
//   //     }
//   //   }
//   // }
// }
// struct Number {}
// pub impl Transition for Number with step(self, lexer:Lexer) {
  
// }

// struct Operator {}

// struct Identifer {}