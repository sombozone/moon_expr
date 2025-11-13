///|
test "Transition::execute" {
  let tokens = Lexer::tokenize(Lexer::new(source="123"))
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0].kind(), Kind::Num)
  assert_eq(tokens[1].kind(), Kind::EOF)
}

test "push eof token" {
  let tokens = Lexer::tokenize(Lexer::new(source=""))
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0].kind(), Kind::EOF)
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

test "number literals - integer and prefixed bases (no fraction/exponent)" {
  // 1) 十进制整数
  let t_int = Lexer::tokenize(Lexer::new(source="12345"))
  assert_eq(t_int.length(), 2)
  assert_eq(t_int[0].kind(), Kind::Num)
  assert_eq(t_int[0].value(), "12345")
  assert_eq(t_int[1].kind(), Kind::EOF)

  // 2) 十六进制 0x1f
  let t_hex = Lexer::tokenize(Lexer::new(source="0x1f"))
  assert_eq(t_hex.length(), 2)
  assert_eq(t_hex[0].kind(), Kind::Num)
  assert_eq(t_hex[0].value(), "0x1f")
  assert_eq(t_hex[1].kind(), Kind::EOF)

  // 3) 八进制 0o17
  let t_oct = Lexer::tokenize(Lexer::new(source="0o17"))
  assert_eq(t_oct.length(), 2)
  assert_eq(t_oct[0].kind(), Kind::Num)
  assert_eq(t_oct[0].value(), "0o17")
  assert_eq(t_oct[1].kind(), Kind::EOF)

  // 4) 二进制 0b1011
  let t_bin = Lexer::tokenize(Lexer::new(source="0b1011"))
  assert_eq(t_bin.length(), 2)
  assert_eq(t_bin[0].kind(), Kind::Num)
  assert_eq(t_bin[0].value(), "0b1011")
  assert_eq(t_bin[1].kind(), Kind::EOF)
}

test "number literals - decimal fractions and exponents (base-10 only)" {
  // 1) 简单小数 0.5
  let t_frac1 = Lexer::tokenize(Lexer::new(source="0.5"))
  assert_eq(t_frac1.length(), 2)
  assert_eq(t_frac1[0].kind(), Kind::Num)
  assert_eq(t_frac1[0].value(), "0.5")
  assert_eq(t_frac1[1].kind(), Kind::EOF)

  // 2) 以点开头的小数 .5
  let t_frac2 = Lexer::tokenize(Lexer::new(source=".5"))
  assert_eq(t_frac2.length(), 2)
  assert_eq(t_frac2[0].kind(), Kind::Num)
  assert_eq(t_frac2[0].value(), ".5")
  assert_eq(t_frac2[1].kind(), Kind::EOF)

  // 3) 科学计数法 1e10
  let t_exp1 = Lexer::tokenize(Lexer::new(source="1e10"))
  assert_eq(t_exp1.length(), 2)
  assert_eq(t_exp1[0].kind(), Kind::Num)
  assert_eq(t_exp1[0].value(), "1e10")
  assert_eq(t_exp1[1].kind(), Kind::EOF)

  // 4) 科学计数法带符号 1.0e-10
  let t_exp2 = Lexer::tokenize(Lexer::new(source="1.0e-10"))
  assert_eq(t_exp2.length(), 2)
  assert_eq(t_exp2[0].kind(), Kind::Num)
  assert_eq(t_exp2[0].value(), "1.0e-10")
  assert_eq(t_exp2[1].kind(), Kind::EOF)

  // 5) 下划线分隔的十进制小数 123_456.789_012
  let t_underscore = Lexer::tokenize(Lexer::new(source="123_456.789_012"))
  assert_eq(t_underscore.length(), 2)
  assert_eq(t_underscore[0].kind(), Kind::Num)
  assert_eq(t_underscore[0].value(), "123_456.789_012")
  assert_eq(t_underscore[1].kind(), Kind::EOF)
}

test "number literals - invalid cases" {
  // 1) 0x 后无数字
  let r1 = try? Lexer::tokenize(Lexer::new(source="0x"))
  let ok1 = match r1 { Err(_) => true; Ok(_) => false }
  assert_eq(ok1, true)

  // 2) 0o 后跟 8/9（非法八进制）
  let r2 = try? Lexer::tokenize(Lexer::new(source="0o8"))
  let ok2 = match r2 { Err(_) => true; Ok(_) => false }
  assert_eq(ok2, true)

  // 3) 0b 后跟 2（非法二进制）
  let r3 = try? Lexer::tokenize(Lexer::new(source="0b2"))
  let ok3 = match r3 { Err(_) => true; Ok(_) => false }
  assert_eq(ok3, true)

  // 4) 小数点后无数字：1.
  let r4 = try? Lexer::tokenize(Lexer::new(source="1."))
  let ok4 = match r4 { Err(_) => true; Ok(_) => false }
  assert_eq(ok4, true)

  // 5) 指数后无数字：1e
  let r5 = try? Lexer::tokenize(Lexer::new(source="1e"))
  let ok5 = match r5 { Err(_) => true; Ok(_) => false }
  assert_eq(ok5, true)

  // 6) 数字后粘连标识符：123abc
  let r6 = try? Lexer::tokenize(Lexer::new(source="123abc"))
  let ok6 = match r6 { Err(_) => true; Ok(_) => false }
  assert_eq(ok6, true)
}

test "number literals - invalid underscore cases" {
  // 十进制整数：连续与结尾下划线
  let r1 = try? Lexer::tokenize(Lexer::new(source="12__34"))
  assert_eq(match r1 { Err(_) => true; Ok(_) => false }, true)
  let r2 = try? Lexer::tokenize(Lexer::new(source="123_"))
  assert_eq(match r2 { Err(_) => true; Ok(_) => false }, true)

  // 十进制分数：段首/连续/结尾下划线
  let r3 = try? Lexer::tokenize(Lexer::new(source="1._2"))
  assert_eq(match r3 { Err(_) => true; Ok(_) => false }, true)
  let r4 = try? Lexer::tokenize(Lexer::new(source="1.2__3"))
  assert_eq(match r4 { Err(_) => true; Ok(_) => false }, true)
  let r5 = try? Lexer::tokenize(Lexer::new(source="1.23_"))
  assert_eq(match r5 { Err(_) => true; Ok(_) => false }, true)
  // 以点开头分数的段首/结尾下划线
  let r5b = try? Lexer::tokenize(Lexer::new(source="._5"))
  assert_eq(match r5b { Err(_) => true; Ok(_) => false }, true)
  let r5c = try? Lexer::tokenize(Lexer::new(source="._"))
  assert_eq(match r5c { Err(_) => true; Ok(_) => false }, true)

  // 十进制指数：段首/连续/结尾下划线
  let r6 = try? Lexer::tokenize(Lexer::new(source="1e_10"))
  assert_eq(match r6 { Err(_) => true; Ok(_) => false }, true)
  let r7 = try? Lexer::tokenize(Lexer::new(source="1e1__0"))
  assert_eq(match r7 { Err(_) => true; Ok(_) => false }, true)
  let r8 = try? Lexer::tokenize(Lexer::new(source="1e10_"))
  assert_eq(match r8 { Err(_) => true; Ok(_) => false }, true)

  // 十六进制：段首/连续/结尾下划线
  let r9 = try? Lexer::tokenize(Lexer::new(source="0x_1"))
  assert_eq(match r9 { Err(_) => true; Ok(_) => false }, true)
  let r10 = try? Lexer::tokenize(Lexer::new(source="0x1__A"))
  assert_eq(match r10 { Err(_) => true; Ok(_) => false }, true)
  let r11 = try? Lexer::tokenize(Lexer::new(source="0x1A_"))
  assert_eq(match r11 { Err(_) => true; Ok(_) => false }, true)

  // 八进制：段首/连续/结尾下划线
  let r12 = try? Lexer::tokenize(Lexer::new(source="0o_7"))
  assert_eq(match r12 { Err(_) => true; Ok(_) => false }, true)
  let r13 = try? Lexer::tokenize(Lexer::new(source="0o7__5"))
  assert_eq(match r13 { Err(_) => true; Ok(_) => false }, true)
  let r14 = try? Lexer::tokenize(Lexer::new(source="0o75_"))
  assert_eq(match r14 { Err(_) => true; Ok(_) => false }, true)

  // 二进制：段首/连续/结尾下划线
  let r15 = try? Lexer::tokenize(Lexer::new(source="0b_1"))
  assert_eq(match r15 { Err(_) => true; Ok(_) => false }, true)
  let r16 = try? Lexer::tokenize(Lexer::new(source="0b10__01"))
  assert_eq(match r16 { Err(_) => true; Ok(_) => false }, true)
  let r17 = try? Lexer::tokenize(Lexer::new(source="0b101_"))
  assert_eq(match r17 { Err(_) => true; Ok(_) => false }, true)
}

test "identifier/operator/string - mixed tokenization" {
  let src = "sum_1 + .5 * func(0xFF, \"hi\\n\")"
  let tokens = Lexer::tokenize(Lexer::new(source=src))
  assert_eq(tokens.length(), 11)

  assert_eq(tokens[0].kind(), Kind::Ident)
  assert_eq(tokens[0].value(), "sum_1")

  assert_eq(tokens[1].kind(), Kind::Oper)
  assert_eq(tokens[1].value(), "+")

  assert_eq(tokens[2].kind(), Kind::Num)
  assert_eq(tokens[2].value(), ".5")

  assert_eq(tokens[3].kind(), Kind::Oper)
  assert_eq(tokens[3].value(), "*")

  assert_eq(tokens[4].kind(), Kind::Ident)
  assert_eq(tokens[4].value(), "func")

  assert_eq(tokens[5].kind(), Kind::Bracket)
  assert_eq(tokens[5].value(), "(")

  assert_eq(tokens[6].kind(), Kind::Num)
  assert_eq(tokens[6].value(), "0xFF")

  assert_eq(tokens[7].kind(), Kind::Oper)
  assert_eq(tokens[7].value(), ",")

  assert_eq(tokens[8].kind(), Kind::Str)
  assert_eq(tokens[8].value(), "\"hi\\n\"")

  assert_eq(tokens[9].kind(), Kind::Bracket)
  assert_eq(tokens[9].value(), ")")

  assert_eq(tokens[10].kind(), Kind::EOF)
}

test "operator aggregation and dot as operator" {
  let src1 = "a==b && c!=d || e<=f"
  let t1 = Lexer::tokenize(Lexer::new(source=src1))
  assert_eq(t1.length(), 12)
  assert_eq(t1[0].kind(), Kind::Ident)
  assert_eq(t1[1].kind(), Kind::Oper)
  assert_eq(t1[1].value(), "==")
  assert_eq(t1[2].kind(), Kind::Ident)
  assert_eq(t1[3].kind(), Kind::Oper)
  assert_eq(t1[3].value(), "&&")
  assert_eq(t1[4].kind(), Kind::Ident)
  assert_eq(t1[5].kind(), Kind::Oper)
  assert_eq(t1[5].value(), "!=")
  assert_eq(t1[6].kind(), Kind::Ident)
  assert_eq(t1[7].kind(), Kind::Oper)
  assert_eq(t1[7].value(), "||")
  assert_eq(t1[8].kind(), Kind::Ident)
  assert_eq(t1[9].kind(), Kind::Oper)
  assert_eq(t1[9].value(), "<=")
  assert_eq(t1[10].kind(), Kind::Ident)
  assert_eq(t1[10].value(), "f")
  assert_eq(t1[11].kind(), Kind::EOF)

  // 单独的 '.' 在非数字场景归类为操作符
  let t2 = Lexer::tokenize(Lexer::new(source="."))
  assert_eq(t2.length(), 2)
  assert_eq(t2[0].kind(), Kind::Oper)
  assert_eq(t2[0].value(), ".")
  assert_eq(t2[1].kind(), Kind::EOF)
}

test "string unterminated error" {
  let r = try? Lexer::tokenize(Lexer::new(source="\"abc"))
  let is_err = match r { Err(_) => true; Ok(_) => false }
  assert_eq(is_err, true)
}

