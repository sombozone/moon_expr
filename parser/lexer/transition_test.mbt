///|
test "Transition::execute" {
  let lexer = Lexer::new(source="123")
  let t1 = Lexer::get_transition(lexer)
  t1.execute(lexer)
  lexer.set_state(State::Number)
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

test "brackets then eof" {
  let lexer = Lexer::new(source="{}")

  // 使用内置的 Lexer::tokenize 执行到 EOF 并返回所有 token
  let tokens = Lexer::tokenize(lexer)
  assert_eq(tokens.length(), 3)

  // 第1个 token: '{'
  assert_eq(tokens[0].kind(), Kind::Bracket)
  assert_eq(tokens[0].value(), "{")
  assert_eq(@lexer.Location::from(tokens[0].location()), 0)
  assert_eq(@lexer.Location::to(tokens[0].location()), 1)

  // 第2个 token: '}'
  assert_eq(tokens[1].kind(), Kind::Bracket)
  assert_eq(tokens[1].value(), "}")
  assert_eq(@lexer.Location::from(tokens[1].location()), 1)
  assert_eq(@lexer.Location::to(tokens[1].location()), 2)

  // 第3个 token: EOF（空值，位置在末尾）
  assert_eq(tokens[2].kind(), Kind::EOF)
  assert_eq(tokens[2].value(), "")
  assert_eq(@lexer.Location::from(tokens[2].location()), 2)
  assert_eq(@lexer.Location::to(tokens[2].location()), 2)
}

