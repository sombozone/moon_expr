///|
/// 测试工具函数

///|
test "is_space function" {
  // 测试常见空白符
  assert_eq(is_space(' '), true)
  assert_eq(is_space('\t'), true)
  assert_eq(is_space('\n'), true)
  assert_eq(is_space('\r'), true)

  // 测试非空白符
  assert_eq(is_space('a'), false)
  assert_eq(is_space('1'), false)
  assert_eq(is_space('_'), false)
  assert_eq(is_space('$'), false)

  // 测试 Unicode 空白符（不间断空格）
  assert_eq(is_space('\u{00A0}'), true)
}

///|
test "is_alphabetic function" {
  // 测试下划线和美元符
  assert_eq(is_alphabetic('_'), true)
  assert_eq(is_alphabetic('$'), true)

  // 测试 ASCII 字母
  assert_eq(is_alphabetic('a'), true)
  assert_eq(is_alphabetic('Z'), true)

  // 测试 Unicode 字母
  assert_eq(is_alphabetic('α'), true) // 希腊字母
  assert_eq(is_alphabetic('变'), true) // 中文字符
  assert_eq(is_alphabetic('é'), true) // 带重音字母

  // 测试非字母
  assert_eq(is_alphabetic('1'), false)
  assert_eq(is_alphabetic(' '), false)
  assert_eq(is_alphabetic('-'), false)
  assert_eq(is_alphabetic('@'), false)
  assert_eq(is_alphabetic('💡'), false) // emoji
}

///|
test "is_alpha_numeric function" {
  // 测试字母
  assert_eq(is_alpha_numeric('a'), true)
  assert_eq(is_alpha_numeric('_'), true)
  assert_eq(is_alpha_numeric('$'), true)
  assert_eq(is_alpha_numeric('变'), true)

  // 测试数字
  assert_eq(is_alpha_numeric('0'), true)
  assert_eq(is_alpha_numeric('9'), true)

  // 测试非字母数字
  assert_eq(is_alpha_numeric(' '), false)
  assert_eq(is_alpha_numeric('-'), false)
  assert_eq(is_alpha_numeric('@'), false)
  assert_eq(is_alpha_numeric('💡'), false)
}

///|
test "is_valid_identifier function - valid cases" {
  // 合法标识符示例
  assert_eq(is_valid_identifier("foo"), true)
  assert_eq(is_valid_identifier("_bar"), true)
  assert_eq(is_valid_identifier("$baz2"), true)
  assert_eq(is_valid_identifier("变量1"), true)
  assert_eq(is_valid_identifier("a"), true)
  assert_eq(is_valid_identifier("_"), true)
  assert_eq(is_valid_identifier("$"), true)
  assert_eq(is_valid_identifier("a1_b2$c3"), true)
}

///|
test "is_valid_identifier function - invalid cases" {
  // 非法标识符示例
  assert_eq(is_valid_identifier(""), false) // 空串
  assert_eq(is_valid_identifier("1abc"), false) // 首字符为数字
  assert_eq(is_valid_identifier("a-b"), false) // 连字符不允许
  assert_eq(is_valid_identifier("a b"), false) // 空白不允许
  assert_eq(is_valid_identifier("a💡"), false) // emoji 非字母数字
  assert_eq(is_valid_identifier("@var"), false) // 特殊字符开头
  assert_eq(is_valid_identifier("a+b"), false) // 运算符字符
  assert_eq(is_valid_identifier("a.b"), false) // 点号不允许
}

///|
test "is_valid_identifier function - edge cases" {
  // 边界情况
  assert_eq(is_valid_identifier("_"), true)
  assert_eq(is_valid_identifier("$"), true)
  assert_eq(is_valid_identifier("a_"), true)
  assert_eq(is_valid_identifier("a$"), true)
  assert_eq(is_valid_identifier("_1"), true)
  assert_eq(is_valid_identifier("$1"), true)

  // 包含数字的标识符
  assert_eq(is_valid_identifier("var123"), true)
  assert_eq(is_valid_identifier("123var"), false) // 数字开头

  // 混合字符
  assert_eq(is_valid_identifier("my_var_123$"), true)
  assert_eq(is_valid_identifier("my-var"), false) // 连字符
}

test "test char"{
  let source = "a 中文 _123 $123 "
  assert_eq(source.get_char(2), Some('中'))
}