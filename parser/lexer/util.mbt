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
/// 判断字符是否是"字母"（包含 `_`、`$` 以及所有 Unicode 字母）
pub fn is_alphabetic(ch : Char) -> Bool {
  // 在MoonBit中，我们需要手动实现Unicode字母检测
  // 使用字符范围来检测字母
  ch == '_' ||
  ch == '$' ||
  (ch >= 'a' && ch <= 'z') ||
  (ch >= 'A' && ch <= 'Z') ||
  // 基本拉丁字母扩展
  (ch >= 'À' && ch <= 'Ö') ||
  (ch >= 'Ø' && ch <= 'ö') ||
  (ch >= 'ø' && ch <= 'ÿ') ||
  // 希腊字母
  (ch >= 'α' && ch <= 'ω') ||
  (ch >= 'Α' && ch <= 'Ω') ||
  // 中文字符范围（基本汉字）
  (ch >= '一' && ch <= '鿿')
}

///|
/// 判断字符是否是"字母或数字"（这里的"字母"含下划线和美元符）
pub fn is_alpha_numeric(ch : Char) -> Bool {
  is_alphabetic(ch) || (ch >= '0' && ch <= '9')
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
  while i < str.length() {
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
