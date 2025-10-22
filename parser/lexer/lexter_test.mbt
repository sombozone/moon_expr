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
    content="Err(Failure(\"Invalid location: start position cannot be greater than end position\"))",
  )
}

///|
test "Lexer::new constructor" {
  let l = @lexer.Lexer::new(source="123")
  inspect(
    Show::to_string(l),
    content="{source: \"123\", tokens: @queue.of([]), err: None, current: {index: 0, bytes: 0}, eof: false}",
  )
}

///|
test "Token::new_empty constructor" {
  let empty_token = @lexer.Token::new_empty()
  inspect(
    Show::to_string(empty_token),
    content="{location: {from: 0, to: 0}, kind: EOF, value: \"\"}",
  )
}

///|
test "Lexer::next" {
  // Test normal character reading
  let lexer = Lexer::new(source="aα中🌍é_❤️ ")
  inspect(lexer.next().unwrap(), content="a")
  inspect(lexer.current().pos(), content="1")
  inspect(lexer.current().index(), content="1")
  inspect(lexer.current().bytes(), content="1")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next().unwrap(), content="α")
  inspect(lexer.current().pos(), content="2")
  inspect(lexer.current().index(), content="2")
  inspect(lexer.current().bytes(), content="3")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next().unwrap(), content="中")
  inspect(lexer.current().pos(), content="3")
  inspect(lexer.current().index(), content="3")
  inspect(lexer.current().bytes(), content="6")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next().unwrap(), content="🌍")
  inspect(lexer.current().pos(), content="4")
  inspect(lexer.current().index(), content="4")
  inspect(lexer.current().bytes(), content="10")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next().unwrap(), content="é")
  inspect(lexer.current().pos(), content="5")
  inspect(lexer.current().index(), content="6")
  inspect(lexer.current().bytes(), content="12")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next().unwrap(), content="_")
  inspect(lexer.current().pos(), content="6")
  inspect(lexer.current().index(), content="7")
  inspect(lexer.current().bytes(), content="13")  
  inspect(lexer.eof(), content="false")

  // “❤️”是由两个码点组成的组合字符（❤ + ️），按码点分别读取
  inspect(lexer.next().unwrap(), content="❤")
  inspect(lexer.current().pos(), content="7")
  inspect(lexer.current().index(), content="8")
  inspect(lexer.current().bytes(), content="16")  
  inspect(lexer.eof(), content="false")
  ignore(lexer.next())
  //inspect(lexer.next().unwrap(), content=" ")
  inspect(lexer.current().pos(), content="8")
  inspect(lexer.current().index(), content="9")
  inspect(lexer.current().bytes(), content="19")  
  inspect(lexer.eof(), content="true")
}

///|
test "Lexer::next/eof" {
  // Test EOF behavior when reading beyond string length
  let lexer = Lexer::new(source=" ")
  inspect(lexer.next().unwrap(), content=" ")

  // Now reading beyond should set EOF and return null character
  inspect(lexer.next().is_empty(), content="true")
  inspect(lexer.eof(), content="true")
}

///|
test "Lexer::next/empty_source" {
  // Test behavior with empty source string
  let lexer = Lexer::new(source="")

  // First read should immediately set EOF and return null character
  inspect(lexer.next().is_empty(), content="true")
  inspect(lexer.eof(), content="true")
}

test "Lexer::backup" {
  // Test backup behavior
  let lexer = Lexer::new(source="a🌍α❤️")
  ignore(lexer.next()) // Consume 'a'
  ignore(lexer.next()) // Consume '🌍'
  ignore(lexer.next()) // Consume 'α'
  ignore(lexer.next()) // Consume '❤️'
  lexer.backup()
  println(lexer.next().unwrap())
  // println(lexer.next().unwrap())
  lexer.backup()
  lexer.backup()
  // println(lexer.next().unwrap())
  lexer.backup()
  println(lexer.next().unwrap())
  // inspect(lexer.next().unwrap(), content="❤️")
  // lexer.backup()
  //  inspect(lexer.next().unwrap(), content="α")
  // lexer.backup()
  // inspect(lexer.next().unwrap(), content="🌍")
}
