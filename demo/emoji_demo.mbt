///|
fn main {
  // 测试你提到的字符比较
  let c : Char = '\u{fe0f}'
  
  println("=== Emoji特殊字符比较测试 ===")
  println("")
  
  // 直接比较
  println("1. 字符 '\\u{fe0f}' == '\\u{fe0f}': " + (c == '\u{fe0f}').to_string())
  println("2. 字符 '\\u{fe0f}' != '\\u{fe0e}': " + (c != '\u{fe0e}').to_string())
  
  // 验证码点值
  println("3. 字符 '\\u{fe0f}' 的码点值: " + c.to_int().to_string())
  
  // 与其他常见字符比较
  println("4. 字符 '\\u{fe0f}' == 'a': " + (c == 'a').to_string())
  println("5. 字符 '\\u{fe0f}' == '1': " + (c == '1').to_string())
  println("6. 字符 '\\u{fe0f}' == '中': " + (c == '中').to_string())
  
  println("")
  println("=== 变体选择符实际应用 ===")
  
  // 创建包含变体选择符的字符串
  let keycap_hash : String = "#\u{fe0f}"
  let keycap_star : String = "*\u{fe0f}"
  
  println("7. 键帽#字符串: '" + keycap_hash + "' (长度: " + keycap_hash.length().to_string() + ")")
  println("8. 键帽*字符串: '" + keycap_star + "' (长度: " + keycap_star.length().to_string() + ")")
  
  // 提取并比较字符
  let hash_char : Char = keycap_hash.get_char(0).unwrap()
  let star_char : Char = keycap_star.get_char(0).unwrap()
  let variation_char : Char = keycap_hash.get_char(1).unwrap()
  
  println("9. 第一个字符是#: " + (hash_char == '#').to_string())
  println("10. 第一个字符是*: " + (star_char == '*').to_string())
  println("11. 第二个字符是变体选择符: " + (variation_char == '\u{fe0f}').to_string())
  
  println("")
  println("=== 其他emoji特殊字符 ===")
  
  // 零宽度连接符
  let zwj : Char = '\u{200d}'
  println("12. 零宽度连接符(U+200D): " + zwj.to_int().to_string())
  
  // 肤色修饰符
  let skin_tone : Char = '\u{1f3fd}'
  println("13. 中等肤色修饰符(U+1F3FD): " + skin_tone.to_int().to_string())
}
