
///|
test "black-box test - using factory function and validation" {
  assert_eq(1 + 1, 2)
  assert_eq(2 + 2, 4)
  inspect([1, 2, 3], content="[1, 2, 3]")
  
  // 使用工厂函数创建 Location
  let l = @lexer.Location::new(from=0, to=1)
  // 使用访问器方法获取位置信息
  assert_eq(@lexer.Location::from(l), 0)
  assert_eq(@lexer.Location::to(l), 1)
  // 仍然可以显示 Location
  inspect(Show::to_string(l), content="{from: 0, to: 1}")
  
  // 测试验证逻辑
  inspect(
    try? @lexer.Location::new(from=2, to=1),
    content="Err(Failure(\"Invalid location: start position cannot be greater than end position\"))"
  )
}

///|
test "Lexer::new constructor" {
  let l = @lexer.Lexer::new(source="123")
  inspect(Show::to_string(l), content="{source: \"123\", tokens: @queue.of([]), err: None, start: 0, end: 0, eof: false}")
}

///|
test "Token::new_empty constructor" {
  let empty_token = @lexer.Token::new_empty()
  inspect(Show::to_string(empty_token), content="{location: {from: 0, to: 0}, kind: EOF, value: \"\"}")
}
