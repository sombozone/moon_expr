///|
test "test char" {
  let source = "a 中文 _123 $123 "
  assert_eq(source.get_char(2), Some('中'))
}

///|
test "character indexing with unicode" {
  let source = "a 中文 _123 $123 "

  // 验证各个位置的字符
  assert_eq(source.get_char(0), Some('a'))
  assert_eq(source.get_char(1), Some(' '))
  assert_eq(source.get_char(2), Some('中'))
  assert_eq(source.get_char(3), Some('文'))
  assert_eq(source.get_char(4), Some(' '))
  assert_eq(source.get_char(5), Some('_'))
  assert_eq(source.get_char(6), Some('1'))
  assert_eq(source.get_char(7), Some('2'))
  assert_eq(source.get_char(8), Some('3'))
  assert_eq(source.get_char(9), Some(' '))
  assert_eq(source.get_char(10), Some('$'))
  assert_eq(source.get_char(11), Some('1'))
  assert_eq(source.get_char(12), Some('2'))
  assert_eq(source.get_char(13), Some('3'))
  assert_eq(source.get_char(14), Some(' '))

  // 验证字符串长度（按字符计数）
  assert_eq(source.length(), 15)

  // 验证超出范围的索引
  assert_eq(source.get_char(15), None)
  assert_eq(source.get_char(-1), None)
}

///|
test "emoji character indexing" {
  let source_with_emoji = "Hello🌍World"

  // 验证emoji字符的位置（注意：emoji在MoonBit中占用2个字符位置）
  assert_eq(source_with_emoji.get_char(0), Some('H'))
  assert_eq(source_with_emoji.get_char(1), Some('e'))
  assert_eq(source_with_emoji.get_char(2), Some('l'))
  assert_eq(source_with_emoji.get_char(3), Some('l'))
  assert_eq(source_with_emoji.get_char(4), Some('o'))
  assert_eq(source_with_emoji.get_char(5), Some('🌍')) // emoji在位置5
  assert_eq(source_with_emoji.get_char(6), None) // 位置6为None（emoji占用的第二个位置）
  assert_eq(source_with_emoji.get_char(7), Some('W'))
  assert_eq(source_with_emoji.get_char(8), Some('o'))
  assert_eq(source_with_emoji.get_char(9), Some('r'))
  assert_eq(source_with_emoji.get_char(10), Some('l'))
  assert_eq(source_with_emoji.get_char(11), Some('d'))
  assert_eq(source_with_emoji.length(), 12) // 总长度包含emoji占用的2个位置
}

///|
test "mixed unicode characters" {
  let mixed = "aα中🌍é_❤️"
  println(mixed.iter().count())

  // 注意：emoji占用2个字符位置，其他Unicode字符占用1个
  assert_eq(mixed.get_char(0), Some('a')) // ASCII
  assert_eq(mixed.get_char(1), Some('α')) // 希腊字母
  assert_eq(mixed.get_char(2), Some('中')) // 中文字符
  assert_eq(mixed.get_char(3), Some('🌍')) // emoji在位置3
  // assert_eq(mixed.get_char(4), None) // emoji占用的第二个位置
  assert_eq(mixed.get_char(5), Some('é')) // 带重音字母
  assert_eq(mixed.get_char(6), Some('_')) // 下划线
  assert_eq(mixed[:][7:], "❤️") // 下划线
  assert_eq(mixed.iter().count()-1, 7) // 总长度包含emoji占用的额外位置
}


test "emoji length and indexing" {
  let s = "a🌍b"
  // 字符长度（码点数）：3
  assert_eq(s.length(), 4)
  // 字节长度：1 + 4 + 1 = 6
  assert_eq(s.to_bytes().length(), 8)

  // 索引：0:'a'  1:'🌍'  2:'b'
  assert_eq(s.get_char(1), Some('🌍'))

  // 单个 emoji 的字节长度
  let emoji_bytes = @encoding/utf8.encode('🌍'.to_string()).length()
  assert_eq(emoji_bytes, 4)
}

test "emoji with variation selectors" {
  // 数字1 + 变体选择符-16 = emoji数字1
  let variation_char = "❤️"

  assert_eq(variation_char.get_char(1).unwrap() == '\u{fe0f}', true)
  
}

test "contains_any" {
  // 数字1 + 变体选择符-16 = emoji数字1
  let s1 = "abc"
    // 不包含 'x', 'y', 'z' 任何一个
    assert_true(s1.contains_any(chars= "d".to_string_view()))
  
} 