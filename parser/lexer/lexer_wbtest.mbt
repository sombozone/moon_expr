///|
test "white-box test - direct access and factory function comparison" {
  // 在白盒测试中可以直接访问包内的所有内容
  let l = Location::{ from: 0, to: 1 }
  inspect(Show::to_string(l), content="{from: 0, to: 1}")
  
  // 也可以使用工厂函数
  let l2 = create_location(from=2, to=3)
  inspect(Show::to_string(l2), content="{from: 2, to: 3}")
  
  // 测试工厂函数的验证逻辑
  inspect(
    try? create_location(from=5, to=4),
    content="Err(Failure(\"Invalid location: start position cannot be greater than end position\"))"
  )
  
  // 甚至可以访问非pub的内容（如果存在）
  let token = Token::{
    location: l,
    kind: Kind::Identifier,
    value: "test"
  }
  inspect(Show::to_string(token), content="{location: {from: 0, to: 1}, kind: Identifier, value: \"test\"}")
}