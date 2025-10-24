///|
test "Transition::execute" {
  let lexer = Lexer::new(source="123")
  let t1 = Lexer::get_transition(lexer)
  t1.execute(lexer)
  lexer.state(State::Number)
  let t2 = Lexer::get_transition(lexer)
  
  t2.execute(lexer)
}