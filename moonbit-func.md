看起来MoonBit核心库的UTF-8模块主要提供整个字符串的编码/解码功能，而不是单个字符的解码。不过，我们可以使用这些模块来构建类似 `utf8.DecodeRuneInString` 的功能。

让我为您展示如何使用MoonBit的现有功能来实现类似功能：

## 1. 使用核心库构建字符解码函数

```moonbit
///|
/// 导入UTF-8编码模块
import "moonbitlang/core/encoding/utf8"

///|
/// 类似Go的utf8.DecodeRuneInString的函数
/// 从字符串的指定位置解码一个UTF-8字符
pub fn decode_rune_in_string(str : String, pos : Int) -> (Int, Char?, Int) {
  if pos >= str.length() {
    return (pos, None, 0)  // 到达字符串末尾
  }
  
  // 使用String的get_char方法，它已经处理了UTF-8解码
  match str.get_char(pos) {
    Some(ch) => {
      // 计算UTF-8字节数
      let encoded = ch.to_string()
      let byte_count = encoded.length()
      (pos + 1, Some(ch), byte_count)
    }
    None => (pos, None, 0)
  }
}

///|
/// 使用BytesView进行更底层的UTF-8解码
pub fn decode_rune_from_bytes(bytes : BytesView, pos : Int) -> (Int, Char?, Int) {
  if pos >= bytes.length() {
    return (pos, None, 0)
  }
  
  // 尝试解码单个字符
  let single_byte = bytes[pos:pos+1]
  match single_byte.get_char(0) {
    Some(ch) => (pos + 1, Some(ch), 1),  // ASCII字符
    
    None => {
      // 可能是多字节UTF-8字符
      // 尝试解码最多4个字节
      let max_bytes = if pos + 4 <= bytes.length() { 4 } else { bytes.length() - pos }
      let potential_bytes = bytes[pos:pos+max_bytes]
      
      // 使用UTF-8解码器
      try {
        let decoded_string = @utf8.decode(potential_bytes)
        match decoded_string.get_char(0) {
          Some(ch) => {
            let byte_count = ch.to_string().length()
            (pos + byte_count, Some(ch), byte_count)
          }
          None => (pos, None, 0)
        }
      } catch {
        _ => (pos, None, 0)  // 解码失败
      }
    }
  }
}
```

## 2. 在Lexer中使用这些函数

```moonbit
///|
/// 增强的Lexer结构，支持字节位置跟踪
struct Lexer {
  source : String
  char_pos : Int      // 字符位置
  byte_pos : Int      // 字节位置（用于低级操作）
  bytes : Bytes       // 原始字节数据
} derive(Show)

///|
/// 创建Lexer
pub fn Lexer::new(source~ : String) -> Lexer {
  let bytes = source.to_bytes()
  Lexer::{
    source,
    char_pos: 0,
    byte_pos: 0,
    bytes
  }
}

///|
/// 使用类似Go的字符解码
pub fn Lexer::next_rune(self : Lexer) -> (Lexer, Char?, Int) {
  if self.char_pos >= self.source.length() {
    return (self, None, 0)
  }
  
  let (new_char_pos, ch_opt, byte_count) = decode_rune_in_string(self.source, self.char_pos)
  
  let new_lexer = Lexer::{
    source: self.source,
    char_pos: new_char_pos,
    byte_pos: self.byte_pos + byte_count,
    bytes: self.bytes
  }
  
  (new_lexer, ch_opt, byte_count)
}

///|
/// 使用字节级别的解码
pub fn Lexer::next_rune_from_bytes(self : Lexer) -> (Lexer, Char?, Int) {
  if self.byte_pos >= self.bytes.length() {
    return (self, None, 0)
  }
  
  let bytes_view = self.bytes[:]
  let (new_byte_pos, ch_opt, byte_count) = decode_rune_from_bytes(bytes_view, self.byte_pos)
  
  // 更新字符位置（近似值）
  let new_char_pos = if byte_count > 0 { self.char_pos + 1 } else { self.char_pos }
  
  let new_lexer = Lexer::{
    source: self.source,
    char_pos: new_char_pos,
    byte_pos: new_byte_pos,
    bytes: self.bytes
  }
  
  (new_lexer, ch_opt, byte_count)
}
```

## 3. 测试和比较

```moonbit
///|
test "decode rune functionality" {
  let test_cases = [
    ("Hello", 0, 'H', 1),
    ("世界", 0, '世', 3),      // 中文字符通常3字节
    ("🌍", 0, '🌍', 4),        // emoji通常4字节
    ("a🌍b", 1, '🌍', 4)       // 从位置1开始
  ]
  
  for (str, start_pos, expected_char, expected_bytes) in test_cases {
    let (new_pos, ch_opt, byte_count) = decode_rune_in_string(str, start_pos)
    assert_eq(ch_opt, Some(expected_char))
    assert_eq(byte_count, expected_bytes)
    assert_eq(new_pos, start_pos + 1)  // 字符位置总是+1
  }
}

///|
test "lexer rune decoding" {
  let lexer = Lexer::new("a🌍世界")
  
  // 第一个字符
  let (lexer1, ch1, bytes1) = lexer.next_rune()
  assert_eq(ch1, Some('a'))
  assert_eq(bytes1, 1)
  assert_eq(lexer1.char_pos, 1)
  assert_eq(lexer1.byte_pos, 1)
  
  // 第二个字符 (emoji)
  let (lexer2, ch2, bytes2) = lexer1.next_rune()
  assert_eq(ch2, Some('🌍'))
  assert_eq(bytes2, 4)
  assert_eq(lexer2.char_pos, 2)
  assert_eq(lexer2.byte_pos, 5)
  
  // 第三个字符 (中文)
  let (lexer3, ch3, bytes3) = lexer2.next_rune()
  assert_eq(ch3, Some('世'))
  assert_eq(bytes3, 3)
  assert_eq(lexer3.char_pos, 3)
  assert_eq(lexer3.byte_pos, 8)
}
```

## 4. 简化版本（推荐）

对于大多数用例，MoonBit内置的字符串操作已经足够：

```moonbit
///|
/// 简化的字符解码（推荐用于大多数情况）
pub fn simple_decode_rune(str : String, pos : Int) -> (Int, Char?) {
  if pos >= str.length() {
    (pos, None)
  } else {
    (pos + 1, str.get_char(pos))
  }
}

///|
/// 在Lexer中使用简化版本
pub fn Lexer::simple_next_rune(self : Lexer) -> (Lexer, Char?) {
  if self.char_pos >= self.source.length() {
    (self, None)
  } else {
    let ch = self.source.get_char(self.char_pos)
    let new_lexer = Lexer::{
      source: self.source,
      char_pos: self.char_pos + 1,
      byte_pos: self.byte_pos,  // 不更新字节位置
      bytes: self.bytes
    }
    (new_lexer, ch)
  }
}
```

## 总结

**MoonBit核心库的UTF-8模块 vs Go的utf8.DecodeRuneInString**：

| 特性 | Go `utf8.DecodeRuneInString` | MoonBit 方案 |
|------|-----------------------------|--------------|
| 单个字符解码 | 是 | 使用 `get_char(pos)` |
| 返回字节数 | 是 | 需要额外计算 |
| 错误处理 | 返回特殊字符 | 返回 `None` |
| 性能 | 高效 | 高效（内置） |
| 使用复杂度 | 中等 | 简单 |

**推荐方案**：
- **对于大多数用例**：直接使用 `str.get_char(pos)`，因为MoonBit的String已经内置UTF-8支持
- **需要字节位置跟踪**：使用自定义的 `decode_rune_in_string` 函数
- **处理原始字节数据**：使用 `@utf8.decode()` 进行批量解码

**在您的Lexer中，最简单的替换方式是**：
```moonbit
// 替换Go的：
// r, size := utf8.DecodeRuneInString(l.input[l.pos:])

// 使用MoonBit的：
let ch = source.get_char(pos)
if ch is Some(c) {
  // 处理字符c
  pos = pos + 1
} else {
  // 处理EOF
}
```

MoonBit的设计让UTF-8处理更加简单，因为字符串操作在语言层面就已经正确处理了Unicode字符。