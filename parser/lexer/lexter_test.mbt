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
  let lexer = Lexer::new(source="aα中🌍é_❤️A")
  inspect(lexer.next_char().unwrap(), content="a")
  inspect(lexer.current().pos(), content="1")
  inspect(lexer.current().index(), content="1")
  inspect(lexer.current().bytes(), content="1")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next_char().unwrap(), content="α")
  inspect(lexer.current().pos(), content="2")
  inspect(lexer.current().index(), content="2")
  inspect(lexer.current().bytes(), content="3")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next_char().unwrap(), content="中")
  inspect(lexer.current().pos(), content="3")
  inspect(lexer.current().index(), content="3")
  inspect(lexer.current().bytes(), content="6")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next_char().unwrap(), content="🌍")
  inspect(lexer.current().pos(), content="4")
  inspect(lexer.current().index(), content="5")
  inspect(lexer.current().bytes(), content="10")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next_char().unwrap(), content="é")
  inspect(lexer.current().pos(), content="5")
  inspect(lexer.current().index(), content="6")
  inspect(lexer.current().bytes(), content="12")
  inspect(lexer.eof(), content="false")

  inspect(lexer.next_char().unwrap(), content="_")
  inspect(lexer.current().pos(), content="6")
  inspect(lexer.current().index(), content="7")
  inspect(lexer.current().bytes(), content="13")  
  inspect(lexer.eof(), content="false")

  // “❤️”是由两个码点组成的组合字符（❤ + ️），按码点分别读取
  inspect(lexer.next_char().unwrap(), content="❤")
  inspect(lexer.current().pos(), content="7")
  inspect(lexer.current().index(), content="9")
  inspect(lexer.current().bytes(), content="16")  
  inspect(lexer.eof(), content="false")
  ignore(lexer.next_char())
  //inspect(lexer.next().unwrap(), content=" ")
  inspect(lexer.current().pos(), content="8")
  inspect(lexer.current().index(), content="10")
  inspect(lexer.current().bytes(), content="17")  
  inspect(lexer.eof(), content="true")
}

///|
test "Lexer::next/eof" {
  // Test EOF behavior when reading beyond string length
  let lexer = Lexer::new(source=" ")
  inspect(lexer.next_char().unwrap(), content=" ")

  // Now reading beyond should set EOF and return null character
  inspect(lexer.next_char().is_empty(), content="true")
  inspect(lexer.eof(), content="true")
}

///|
test "Lexer::next/empty_source" {
  // Test behavior with empty source string
  let lexer = Lexer::new(source="")

  // First read should immediately set EOF and return null character
  inspect(lexer.next_char().is_empty(), content="true")
  println(lexer.current())
  inspect(lexer.eof(), content="true")
}

test "Lexer::backup" {
  // Test backup behavior
  let lexer = Lexer::new(source="a🌍α❤️")
  ignore(lexer.next_char()) // Consume 'a'
  ignore(lexer.next_char()) // Consume '🌍'
  ignore(lexer.next_char()) // Consume 'α'
  ignore(lexer.next_char()) // Consume '❤️'
  lexer.rewind_back()
  inspect(lexer.current(), content="{pos: 3, index: 4, bytes: 7}")
  lexer.rewind_back()
  inspect(lexer.current(), content="{pos: 2, index: 3, bytes: 5}")
  lexer.rewind_back()
  inspect(lexer.current(), content="{pos: 1, index: 1, bytes: 1}")
  lexer.rewind_back()
  inspect(lexer.current(), content="{pos: 0, index: 0, bytes: 0}")
}


///|
test "Lexer::get_word" {
  let lexer = Lexer::new(source="a🌍α❤️hello world 🤣A")
  
 // 移动到 '🌍' 之后，并设置切片起点
  ignore(lexer.next_char()) // 'a'
  ignore(lexer.next_char()) // '🌍'
  inspect(lexer.get_slice(), content="a🌍")
  lexer.commit()

  // 读取 'α'，此时切片应为 "α"
  ignore(lexer.next_char()) // 'α'
  let t1 = lexer.get_slice()
  inspect(t1, content="α")

  // 读取“❤️”的第一个码点 '❤'，切片视图应扩展为 "α❤"
  ignore(lexer.next_char()) // '❤'
  //ignore(lexer.next())
  let t2 = lexer.get_slice()
  inspect(t2, content="α❤️")

  // 读取 "hello " 并断言
  lexer.commit()
  ignore(lexer.next_char()) // 'h'
  ignore(lexer.next_char()) // 'e'
  ignore(lexer.next_char()) // 'l'
  ignore(lexer.next_char()) // 'l'
  ignore(lexer.next_char()) // 'o'
  println(lexer.get_slice())
  inspect(lexer.get_slice(), content="hello")

  // 读取 "world 🤣 " 并断言
  lexer.commit()
  ignore(lexer.next_char()) // ' '
  ignore(lexer.next_char()) // 'w'
  ignore(lexer.next_char()) // 'o'
  ignore(lexer.next_char()) // 'r'
  ignore(lexer.next_char()) // 'l'
  ignore(lexer.next_char()) // 'd'
  ignore(lexer.next_char()) // ' '
  ignore(lexer.next_char()) // '🤣'
  ignore(lexer.next_char()) // ' '
  println(lexer.current())
  println(lexer.current())
  inspect(lexer.get_slice(), content=" world 🤣A")
}

test "Lexer::peek_current" {
  let lexer = Lexer::new(source="a🌍α❤️hello world 🤣A")
  inspect(lexer.peek_current(), content="a")
  inspect(lexer.current(), content="{pos: 0, index: 0, bytes: 0}")
  ignore(lexer.next_char())
  inspect(lexer.peek_current(), content="🌍")
  inspect("{pos: \{lexer.current().pos}, index: \{lexer.current().index}}", content="{pos: 1, index: 1}")
  ignore(lexer.next_char())
  inspect(lexer.peek_current(), content="α")
  inspect("{pos: \{lexer.current().pos}, index: \{lexer.current().index}}", content="{pos: 2, index: 3}")
}

test "Lexer::find_next_position" {
  let lexer = Lexer::new(source="a🌍α❤️hello world 🤣A")
  inspect(lexer.find_next_position(lexer.current()), content="{pos: 1, index: 1, bytes: 0}")
  ignore(lexer.next_char())
  inspect(lexer.find_next_position(lexer.current()), content="{pos: 2, index: 3, bytes: 0}")
  ignore(lexer.next_char())
  inspect(lexer.find_next_position(lexer.current()), content="{pos: 3, index: 4, bytes: 0}")
  ignore(lexer.next_char())
  inspect(lexer.find_next_position(lexer.current()), content="{pos: 4, index: 6, bytes: 0}")
  ignore(lexer.next_char())
  inspect(lexer.find_next_position(lexer.current()), content="{pos: 5, index: 7, bytes: 0}")
}

