///|
/// 使用卫语句(guard clause)从多层 JSON 中提取特定字段
/// - 基于 core 的 Json/FromJson/ToJson
/// - 提供 async/io 读取 JSON 的示例入口
///|

// 定义错误类型，用于清晰的错误处理
suberror ExtractError {
  ParseError(String)
  TypeMismatch(ctx~ : String, detail~ : String)
  MissingField(field~ : String)
  IOReadError(String)
}
derive(Show, Eq)

// 定义 JSON 数据结构类型（多层嵌套）
struct Profile {
  name : String
  age : Int
}
derive(FromJson, ToJson, Show, Eq)

struct User {
  id : Int
  profile : Profile
}
derive(FromJson, ToJson, Show, Eq)

// 为了演示“字段可能缺失”的卫语句，设置 theme 为可选
struct Settings {
  theme : Option[String]
}
derive(FromJson, ToJson, Show, Eq)

struct Root {
  user : User
  settings : Settings
}
derive(FromJson, ToJson, Show, Eq)

///|
/// 从 Json 中精确提取 1-2 个字段：
/// - 必须字段：user.profile.name : String
/// - 可选字段：settings.theme : Option[String]，缺失时给默认值
/// 使用卫语句在条件不满足时尽早返回错误或默认值
///|
fn extract_user_name_and_theme(json : Json) -> Result[(String, String), ExtractError] {
  // 1) 类型转换：Json -> Root（失败就早返回 TypeMismatch）
  let root : Root =
    (try {
      @json.from_json(json)
    } catch { e =>
      return Err(ExtractError::TypeMismatch(ctx="Root", detail=e.to_string()))
    })

  // 2) 必须字段存在性与类型检查（typed结构保证类型，仍可做业务校验）
  let name = root.user.profile.name
  if name.length() == 0 { // 卫语句：空字符串视为不合法
    return Err(ExtractError::MissingField(field="user.profile.name"))
  }

  // 3) 可选字段：缺失时返回默认值（卫语句）
  let theme = match root.settings.theme {
    Some(t) => t
    None => "light" // 默认值
  }

  Ok((name, theme))
}

///|
/// 从字符串解析并提取字段（同步版本）
/// - 展示 parse -> from_json -> 提取 的完整卫语句链路
///|
fn extract_from_string(s : String) -> Result[(String, String), ExtractError] {
  // 空内容检查
  if s.length() == 0 {
    return Err(ExtractError::ParseError("empty input"))
  }

  // 解析字符串为 Json（@json.parse 是带错误的函数，用 try/catch 捕获）
  let json = (try {
    @json.parse(s)
  } catch { e =>
    return Err(ExtractError::ParseError(e.to_string()))
  })

  // 提取字段
  extract_user_name_and_theme(json)
}

///|
/// 使用 async/io 读取 JSON 并提取字段（异步版本）
/// - 读取文件内容 -> parse -> from_json -> 提取
/// 注意：moonbitlang/async 在当前平台的具体支持情况以官方说明为准
///|
async fn extract_from_path(path : String) -> (String, String) raise ExtractError {
  // 卫语句：路径合法性
  if path.length() == 0 {
    raise ExtractError::IOReadError("empty path")
  }

  // 说明：此函数应使用 moonbitlang/async 的 @async.path(path).read_all() 读取文件。
  // 由于当前环境无法安装外部依赖（网络受限），此处保留接口并返回可读错误。
  raise ExtractError::IOReadError("async/io not available in current environment")
}

///|
/// 简单测试：演示同步提取与错误分支
///|
test "json guard: extract fields" {
  let ok_json = "{\"user\": {\"id\": 42, \"profile\": {\"name\": \"Alice\", \"age\": 30}}, \"settings\": {\"theme\": \"dark\"}}"

  match extract_from_string(ok_json) {
    Ok((name, theme)) => {
      assert_eq(name, "Alice")
      assert_eq(theme, "dark")
    }
    Err(_e) => panic()
  }

  // theme 缺失时，使用默认值 "light"
  let no_theme_json = "{\"user\": {\"id\": 1, \"profile\": {\"name\": \"Bob\", \"age\": 20}}, \"settings\": {}}"
  match extract_from_string(no_theme_json) {
    Ok((name, theme)) => {
      assert_eq(name, "Bob")
      assert_eq(theme, "light")
    }
    Err(_e) => panic()
  }

  // name 为空字符串触发 MissingField 卫语句
  let bad_name_json = "{\"user\": {\"id\": 2, \"profile\": {\"name\": \"\", \"age\": 18}}, \"settings\": {\"theme\": \"dark\"}}"
  match extract_from_string(bad_name_json) {
    Ok(_) => panic()
    Err(e) => assert_eq(e, ExtractError::MissingField(field="user.profile.name"))
  }
}