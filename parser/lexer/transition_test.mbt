///|
test "Transition::execute" {
  let lexer = Lexer::new(source="123")
  let t1 = Lexer::get_transition(lexer)
  t1.execute(lexer)
  lexer.state(State::Number)
  let t2 = Lexer::get_transition(lexer)
  
  t2.execute(lexer)
}

test "push eof token" {
  let lexer = Lexer::new(source="")
  let mut t1 = Lexer::get_transition(lexer)
  t1.execute(lexer)
  
  t1 = Lexer::get_transition(lexer)
  t1.execute(lexer)

  inspect(lexer.eof(),content="true")
  inspect(lexer.tokens()[0].kind,content="EOF")
}

test "push eof token" {
  let lexer = Lexer::new(source="{}")
  let  t1 = Lexer::get_transition(lexer)
  t1.execute(lexer)
  
  // t1 = Lexer::get_transition(lexer)
  // t1.execute(lexer)

  // t1 = Lexer::get_transition(lexer)
  // t1.execute(lexer)
  
  // t1 = Lexer::get_transition(lexer)
  // t1.execute(lexer) 
  println(lexer.tokens())
}

