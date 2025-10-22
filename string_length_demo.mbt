///|
/// 演示 String::length 和 String::char_length 的区别
///
/// String::length 返回 UTF-16 码元数量
/// String::char_length 返回 Unicode 字符数量
///
/// 对于包含代理对（surrogate pairs）的字符（如 emoji），
/// String::length 会返回 2，而 String::char_length 会返回 1
///|
test "字符串长度计算对比" {
  // 基本 ASCII 字符 - 两种方法结果相同
  let ascii_str = "hello"
  inspect(String::length(ascii_str), content="5")
  inspect(String::char_length(ascii_str), content="5")
  
  // 中文 - 两种方法结果相同（UTF-16 中每个中文字符占 2 个码元）
  let chinese_str = "你好世界"
  inspect(String::length(chinese_str), content="4")
  inspect(String::char_length(chinese_str), content="4")
  
  // Emoji 表情 - 这里会有区别！
  // 😀 这个 emoji 在 UTF-16 中需要 2 个码元（代理对）
  let emoji_str = "😀"
  inspect(String::length(emoji_str), content="2")
  inspect(String::char_length(emoji_str), content="1")
  
  // 混合字符串
  let mixed_str = "hello😀world"
  inspect(String::length(mixed_str), content="12")  // 5 + 2 + 5 = 12
  inspect(String::char_length(mixed_str), content="11") // 5 + 1 + 5 = 11
  
  // 更多 emoji 示例
  let emojis = "🎉🚀🌟"
  inspect(String::length(emojis), content="6")  // 每个 emoji 2 个码元
  inspect(String::char_length(emojis), content="3") // 每个 emoji 1 个字符
}