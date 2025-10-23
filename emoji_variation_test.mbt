///|
/// 测试emoji中的特殊字符，特别是变体选择符
///
/// 变体选择符-16 (U+FE0F) 用于强制将前一个字符显示为emoji样式
/// 变体选择符-15 (U+FE0E) 用于强制将前一个字符显示为文本样式
///
test "emoji variation selectors" {
  // 变体选择符-16 (U+FE0F) - 强制emoji样式
  let variation_selector_16 : Char = '\u{fe0f}'
  let variation_selector_15 : Char = '\u{fe0e}'

  // 验证字符值（将字符转换为字符串进行inspect）
  inspect(variation_selector_16.to_string(), content="\u{fe0f}")
  println("c\u{fe0f}c")
  inspect(variation_selector_15.to_string(), content="\u{fe0e}")

  // 验证字符比较
  assert_eq(variation_selector_16 == '\u{fe0f}', true)
  assert_eq(variation_selector_15 == '\u{fe0e}', true)
  assert_eq(variation_selector_16 == variation_selector_15, false)
}

///|
/// 测试包含变体选择符的emoji组合
/// 例如：数字 + 变体选择符 = emoji数字
///
test "emoji with variation selectors" {
  // 数字1 + 变体选择符-16 = emoji数字1
  let emoji_one : String = "1\u{fe0f}"
  let emoji_one_char : Char = '1'
  let variation_char = "❤️"

  // 验证字符串长度
  assert_eq(emoji_one.length(), 2)

  // 验证字符内容
  assert_eq(emoji_one.get_char(0), Some('1'))
  assert_eq(emoji_one.get_char(1), Some('\u{fe0f}'))

  // 直接比较字符
  assert_eq(emoji_one_char == '1', true)
  assert_eq(variation_char.get_char(1).unwrap() == '\u{fe0f}', true)

  // 验证字符码点值
  assert_eq(emoji_one_char.to_int(), 49) // '1' 的Unicode码点
  // assert_eq(variation_char.to_int(), 65039) // U+FE0F 的码点
}

///|
/// 测试常见的emoji特殊字符
///
test "common emoji special characters" {
  // 零宽度连接符 (U+200D) - 用于emoji组合
  let zero_width_joiner : Char = '\u{200d}'

  // 表情符号修饰符 (U+1F3FB - U+1F3FF) - 肤色修饰符
  let light_skin_tone : Char = '\u{1f3fb}'
  let medium_light_skin_tone : Char = '\u{1f3fc}'
  let medium_skin_tone : Char = '\u{1f3fd}'
  let medium_dark_skin_tone : Char = '\u{1f3fe}'
  let dark_skin_tone : Char = '\u{1f3ff}'

  // 验证这些特殊字符
  assert_eq(zero_width_joiner == '\u{200d}', true)
  assert_eq(light_skin_tone == '\u{1f3fb}', true)
  assert_eq(medium_light_skin_tone == '\u{1f3fc}', true)
  assert_eq(medium_skin_tone == '\u{1f3fd}', true)
  assert_eq(medium_dark_skin_tone == '\u{1f3fe}', true)
  assert_eq(dark_skin_tone == '\u{1f3ff}', true)

  // 验证码点值
  assert_eq(zero_width_joiner.to_int(), 8205) // U+200D
  assert_eq(light_skin_tone.to_int(), 127995) // U+1F3FB
  assert_eq(medium_light_skin_tone.to_int(), 127996) // U+1F3FC
  assert_eq(medium_skin_tone.to_int(), 127997) // U+1F3FD
  assert_eq(medium_dark_skin_tone.to_int(), 127998) // U+1F3FE
  assert_eq(dark_skin_tone.to_int(), 127999) // U+1F3FF
}

///|
/// 测试emoji组合序列
///
test "emoji combination sequences" {
  // 家庭emoji: 男人 + 零宽度连接符 + 女人 + 零宽度连接符 + 女孩
  let family : String = "👨\u{200d}👩\u{200d}👧"

  // 带肤色的emoji: 举手 + 肤色修饰符
  let raised_hand_with_skin_tone : String = "✋\u{1f3fd}"

  // 验证字符串长度
  assert_eq(family.length(), 5) // 每个emoji占2个位置，零宽度连接符占1个
  assert_eq(raised_hand_with_skin_tone.length(), 3) // emoji + 修饰符

  // 验证字符内容
  assert_eq(family.get_char(0), Some('👨'))
  assert_eq(family.get_char(1), Some('\u{200d}'))
  assert_eq(family.get_char(2), Some('👩'))
  assert_eq(family.get_char(3), Some('\u{200d}'))
  assert_eq(family.get_char(4), Some('👧'))
  assert_eq(raised_hand_with_skin_tone.get_char(0), Some('✋'))
  assert_eq(raised_hand_with_skin_tone.get_char(1), Some('\u{1f3fd}'))
}

///|
/// 测试变体选择符的实际应用
///
test "variation selector practical examples" {
  // 使用变体选择符强制显示为emoji
  let keycap_number : String = "#\u{fe0f}" // emoji键帽#
  let asterisk_emoji : String = "*\u{fe0f}" // emoji键帽*

  // 不使用变体选择符的普通字符
  let regular_hash : String = "#"
  let regular_asterisk : String = "*"

  // 验证长度差异
  assert_eq(keycap_number.length(), 2)
  assert_eq(regular_hash.length(), 1)
  assert_eq(asterisk_emoji.length(), 2)
  assert_eq(regular_asterisk.length(), 1)

  // 验证字符内容
  assert_eq(keycap_number.get_char(0), Some('#'))
  assert_eq(keycap_number.get_char(1), Some('\u{fe0f}'))
  assert_eq(regular_hash.get_char(0), Some('#'))

  // 直接比较字符
  let hash_char : Char = '#'
  let variation_char : Char = '\u{fe0f}'
  assert_eq(hash_char == '#', true)
  assert_eq(variation_char == '\u{fe0f}', true)
  assert_eq(hash_char == variation_char, false)
}
