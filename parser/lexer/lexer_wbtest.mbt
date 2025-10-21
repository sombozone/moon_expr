///|
test "white-box test - direct access and factory function comparison" {
  // 在白盒测试中可以直接访问包内的所有内容
  let l = Location::{ from: 0, to: 1 }
  inspect(Show::to_string(l), content="{from: 0, to: 1}")
  
  // 也可以使用工厂函数
  let l2 =  Location::new(from=2, to=3)
  inspect(Show::to_string(l2), content="{from: 2, to: 3}")
  
  // 测试工厂函数的验证逻辑
  inspect(
    try? Location::new(from=5, to=4),
    content="Err(Failure(\"Invalid location: start position cannot be greater than end position\"))"
  )
  
  // 甚至可以访问非pub的内容（如果存在）
  let token = Token::{
    location: l,
    kind: Kind::Ident,
    value: "test"
  }
  inspect(Show::to_string(token), content="{location: {from: 0, to: 1}, kind: Ident, value: \"test\"}")
}

///|
test "white-box test - Lexer::new constructor" {
  // 在白盒测试中可以直接调用构造函数
  let lexer = Lexer::new(source="hello world")
  inspect(Show::to_string(lexer), content="{source: \"hello world\", tokens: @queue.of([]), err: None, start: 0, end: 0, eof: false}")
}

///|
test "white-box test - Token constructors" {
  // 测试Token::new_empty构造函数
  let empty_token = Token::new_empty()
  inspect(Show::to_string(empty_token), content="{location: {from: 0, to: 0}, kind: EOF, value: \"\"}")
  
  // 测试Token::new构造函数
  let location = Location::new(from=1, to=5)
  let normal_token = Token::new(location=location, kind=Kind::Ident, value="hello")
  inspect(Show::to_string(normal_token), content="{location: {from: 1, to: 5}, kind: Ident, value: \"hello\"}")
}