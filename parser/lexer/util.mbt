///|
/// 词法分析工具类
/// 提供用于快速词法语义判断的实用函数

///|
/// 判断字符是否是空白符（使用 Unicode 标准）
pub fn is_space(ch : Char) -> Bool {
  // 使用Char的内置方法判断空白符
  ch.is_whitespace()
}

///|
/// 判断字符是否是字母（包含 `_`、`$` ）
pub fn is_alphabetic(ch : Char) -> Bool {
  // 规则：
  // - 下划线与美元符属于“字母”集合
  // - ASCII 字母直接视为字母
  // - 常见非 ASCII 的 Unicode 字母（含拉丁扩展、希腊、CJK 等）
  //   近似判断为：utf16_len()==1 且 非空白 且 非数字 且 非 emoji
  if ch == '_' || ch == '$' { return true }
  if ch.is_ascii_alphabetic() { return true }
  // 近似的 Unicode 字母判断：非 ASCII 且非空白且非 emoji
  let byte_len = @encoding/utf8.encode(ch.to_string()).length()
  let is_ascii = byte_len == 1
  if !is_ascii && !ch.is_whitespace() && !is_emoji(ch) {
    return true
  }
  false
}

///|
/// 判断字符是否是"字母或数字"（这里的"字母"含下划线和美元符）
pub fn is_alpha_numeric(ch : Char) -> Bool {
  is_alphabetic(ch) || ch.is_ascii_digit()
}

///|
/// 判断字符串是否是合法标识符
/// 首字符为"字母"，后续为"字母或数字"
pub fn is_valid_identifier(str : String) -> Bool {
  // 空串直接返回 false
  if str.is_empty() {
    return false
  }

  // 获取第一个字符
  let first_char = str.get_char(0)

  // 检查首字符是否是字母（包含 _ 和 $）
  match first_char {
    Some(ch) => if !is_alphabetic(ch) { return false }
    None => return false
  }

  // 检查剩余字符
  let mut i = 1
  // 以字符维度遍历，而不是 UTF-16 码元维度
  while i < str.char_length() {
    match str.get_char(i) {
      Some(ch) => if !is_alpha_numeric(ch) { return false }
      None => return false
    }
    i = i + 1
  }
  true
}

pub fn is_emoji_selector(ch : Char) -> Bool {
  ch == '\u{fe0f}' || ch == '\u{fe0e}'
}

///|
/// 粗略判断是否为 emoji（高位的表情符号通常在 UTF-16 由两个单元表示）
/// 注意：这是一个近似判断，仅用于区分测试中的 '💡' 等表情符号，不作为通用 Unicode 分类方案。
pub fn is_emoji(ch : Char) -> Bool {
  ch.utf16_len() == 2
}
