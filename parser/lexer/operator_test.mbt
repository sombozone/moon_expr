///|
/// 操作符模块测试套件 - 仅使用公共API

///|
test "find_unary_operator function" {
  // 测试找到一元操作符
  let minus_op = find_unary_operator("-")
  let plus_op = find_unary_operator("+")
  let not_op = find_unary_operator("!")
  let not_keyword = find_unary_operator("not")

  // 检查操作符存在
  assert_eq(minus_op is Some(_), true)
  assert_eq(plus_op is Some(_), true)
  assert_eq(not_op is Some(_), true)
  assert_eq(not_keyword is Some(_), true)

  // 测试找不到的情况
  let unknown_op = find_unary_operator("unknown")
  assert_eq(unknown_op is None, true)
}

///|
test "find_binary_operator function" {
  // 测试找到二元操作符
  let plus_op = find_binary_operator("+")
  let and_op = find_binary_operator("and")
  let eq_op = find_binary_operator("==")
  let power_op = find_binary_operator("**")

  // 检查操作符存在
  assert_eq(plus_op is Some(_), true)
  assert_eq(and_op is Some(_), true)
  assert_eq(eq_op is Some(_), true)
  assert_eq(power_op is Some(_), true)

  // 测试找不到的情况
  let unknown_op = find_binary_operator("unknown")
  assert_eq(unknown_op is None, true)
}

///|
test "Operator::is_comparison method" {
  let lt = find_binary_operator("<").unwrap()
  let gt = find_binary_operator(">").unwrap()
  let lte = find_binary_operator("<=").unwrap()
  let gte = find_binary_operator(">=").unwrap()
  let plus = find_binary_operator("+").unwrap()
  assert_eq(lt.is_comparison(), true)
  assert_eq(gt.is_comparison(), true)
  assert_eq(lte.is_comparison(), true)
  assert_eq(gte.is_comparison(), true)
  assert_eq(plus.is_comparison(), false)
}

///|
test "Operator::is_boolean method" {
  let and_op = find_binary_operator("and").unwrap()
  let or_op = find_binary_operator("or").unwrap()
  let and_symbol = find_binary_operator("&&").unwrap()
  let or_symbol = find_binary_operator("||").unwrap()
  let plus = find_binary_operator("+").unwrap()
  assert_eq(and_op.is_boolean(), true)
  assert_eq(or_op.is_boolean(), true)
  assert_eq(and_symbol.is_boolean(), true)
  assert_eq(or_symbol.is_boolean(), true)
  assert_eq(plus.is_boolean(), false)
}

///|
test "Operator::is_arithmetic method" {
  let plus = find_binary_operator("+").unwrap()
  let minus = find_binary_operator("-").unwrap()
  let multiply = find_binary_operator("*").unwrap()
  let divide = find_binary_operator("/").unwrap()
  let modulo = find_binary_operator("%").unwrap()
  let power = find_binary_operator("**").unwrap()
  let and_op = find_binary_operator("and").unwrap()
  assert_eq(plus.is_arithmetic(), true)
  assert_eq(minus.is_arithmetic(), true)
  assert_eq(multiply.is_arithmetic(), true)
  assert_eq(divide.is_arithmetic(), true)
  assert_eq(modulo.is_arithmetic(), true)
  assert_eq(power.is_arithmetic(), true)
  assert_eq(and_op.is_arithmetic(), false)
}

///|
test "Operator::is_equality method" {
  let eq = find_binary_operator("==").unwrap()
  let neq = find_binary_operator("!=").unwrap()
  let lt = find_binary_operator("<").unwrap()
  assert_eq(eq.is_equality(), true)
  assert_eq(neq.is_equality(), true)
  assert_eq(lt.is_equality(), false)
}

///|
test "Operator::is_collection method" {
  let in_op = find_binary_operator("in").unwrap()
  let contains = find_binary_operator("contains").unwrap()
  let matches = find_binary_operator("matches").unwrap()
  let starts_with = find_binary_operator("startsWith").unwrap()
  let ends_with = find_binary_operator("endsWith").unwrap()
  let plus = find_binary_operator("+").unwrap()
  assert_eq(in_op.is_collection(), true)
  assert_eq(contains.is_collection(), true)
  assert_eq(matches.is_collection(), true)
  assert_eq(starts_with.is_collection(), true)
  assert_eq(ends_with.is_collection(), true)
  assert_eq(plus.is_collection(), false)
}

///|
test "Operator::is_range method" {
  let range = find_binary_operator("..").unwrap()
  let plus = find_binary_operator("+").unwrap()
  assert_eq(range.is_range(), true)
  assert_eq(plus.is_range(), false)
}

///|
test "Operator::is_null_coalescing method" {
  let null_coalesce = find_binary_operator("??").unwrap()
  let plus = find_binary_operator("+").unwrap()
  assert_eq(null_coalesce.is_null_coalescing(), true)
  assert_eq(plus.is_null_coalescing(), false)
}

///|
test "Operator precedence comparison methods" {
  let plus = find_binary_operator("+").unwrap()
  let multiply = find_binary_operator("*").unwrap()
  let power = find_binary_operator("**").unwrap()

  // plus < multiply
  assert_eq(plus.less_precedence(multiply), true)
  assert_eq(plus.equal_precedence(multiply), false)
  assert_eq(plus.greater_precedence(multiply), false)

  // multiply < power
  assert_eq(multiply.less_precedence(power), true)
  assert_eq(multiply.equal_precedence(power), false)
  assert_eq(multiply.greater_precedence(power), false)

  // 相同优先级
  let minus = find_binary_operator("-").unwrap()
  assert_eq(plus.equal_precedence(minus), true)
  assert_eq(plus.less_precedence(minus), false)
  assert_eq(plus.greater_precedence(minus), false)
}

///|
test "Operator::allow_negate_suffix method" {
  let contains = find_binary_operator("contains").unwrap()
  let matches = find_binary_operator("matches").unwrap()
  let starts_with = find_binary_operator("startsWith").unwrap()
  let ends_with = find_binary_operator("endsWith").unwrap()
  let in_op = find_binary_operator("in").unwrap()
  let plus = find_binary_operator("+").unwrap()
  assert_eq(contains.allow_negate_suffix(), true)
  assert_eq(matches.allow_negate_suffix(), true)
  assert_eq(starts_with.allow_negate_suffix(), true)
  assert_eq(ends_with.allow_negate_suffix(), true)
  assert_eq(in_op.allow_negate_suffix(), true)
  assert_eq(plus.allow_negate_suffix(), false)
}

///|
test "get_all_unary_operators function" {
  let unary_ops = get_all_unary_operators()

  // 检查是否包含所有一元操作符
  assert_eq(unary_ops.contains("-"), true)
  assert_eq(unary_ops.contains("+"), true)
  assert_eq(unary_ops.contains("!"), true)
  assert_eq(unary_ops.contains("not"), true)

  // 检查不包含二元操作符
  assert_eq(unary_ops.contains("and"), false)
  assert_eq(unary_ops.contains("+"), true) // 注意："+" 同时存在于一元和二元操作符中

  // 检查数组长度
  assert_eq(unary_ops.length(), 4)
}

///|
test "get_all_binary_operators function" {
  let binary_ops = get_all_binary_operators()

  // 检查是否包含一些关键二元操作符
  assert_eq(binary_ops.contains("+"), true)
  assert_eq(binary_ops.contains("-"), true)
  assert_eq(binary_ops.contains("*"), true)
  assert_eq(binary_ops.contains("and"), true)
  assert_eq(binary_ops.contains("or"), true)
  assert_eq(binary_ops.contains("=="), true)
  assert_eq(binary_ops.contains("**"), true)
  assert_eq(binary_ops.contains("??"), true)

  // 检查不包含一元操作符（除了同时存在的操作符）
  assert_eq(binary_ops.contains("not"), false)

  // 检查数组长度（应该包含所有定义的二元操作符）
  assert_eq(binary_ops.length() > 15, true)
}

///|
test "is_unary_operator function" {
  assert_eq(is_unary_operator("-"), true)
  assert_eq(is_unary_operator("+"), true)
  assert_eq(is_unary_operator("!"), true)
  assert_eq(is_unary_operator("not"), true)
  assert_eq(is_unary_operator("and"), false)
  assert_eq(is_unary_operator("unknown"), false)
}

///|
test "is_binary_operator function" {
  assert_eq(is_binary_operator("+"), true)
  assert_eq(is_binary_operator("-"), true)
  assert_eq(is_binary_operator("*"), true)
  assert_eq(is_binary_operator("and"), true)
  assert_eq(is_binary_operator("or"), true)
  assert_eq(is_binary_operator("not"), false)
  assert_eq(is_binary_operator("unknown"), false)
}

///|
test "operator precedence hierarchy" {
  // 测试操作符优先级层次结构
  let or_op = find_binary_operator("or").unwrap()
  let and_op = find_binary_operator("and").unwrap()
  let eq_op = find_binary_operator("==").unwrap()
  let plus_op = find_binary_operator("+").unwrap()
  let multiply_op = find_binary_operator("*").unwrap()
  let power_op = find_binary_operator("**").unwrap()
  let null_coalesce = find_binary_operator("??").unwrap()

  // 验证优先级顺序：or < and < == < + < * < ** < ??
  assert_eq(or_op.less_precedence(and_op), true)
  assert_eq(and_op.less_precedence(eq_op), true)
  assert_eq(eq_op.less_precedence(plus_op), true)
  assert_eq(plus_op.less_precedence(multiply_op), true)
  assert_eq(multiply_op.less_precedence(power_op), true)
  assert_eq(power_op.less_precedence(null_coalesce), true)
}
