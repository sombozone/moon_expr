///|
/// 定义结合律枚举
priv enum Associativity {
  Left
  Right
} derive(Show, Eq)

///|
/// 定义操作符结构体
struct Operator {
  op : String
  precedence : Int
  associativity : Associativity
} derive(Show, Eq)

///|
/// 定义一元操作符常量，map[String]Operator
let unary_operators : Map[String, Operator] = {
  "-": Operator::{
    op: "-",
    precedence: 90,
    associativity: Associativity::Right,
  },
  "+": Operator::{
    op: "+",
    precedence: 90,
    associativity: Associativity::Right,
  },
  "!": Operator::{ op: "!", precedence: 50, associativity: Associativity::Left },
  "not": Operator::{
    op: "not",
    precedence: 50,
    associativity: Associativity::Left,
  },
}

///|
/// 定义二元操作符常量，map[String]Operator
let binary_operators : Map[String, Operator] = {
  "|": Operator::{ op: "|", precedence: 0, associativity: Associativity::Left },
  "or": Operator::{
    op: "or",
    precedence: 10,
    associativity: Associativity::Left,
  },
  "||": Operator::{
    op: "||",
    precedence: 10,
    associativity: Associativity::Left,
  },
  "and": Operator::{
    op: "and",
    precedence: 15,
    associativity: Associativity::Left,
  },
  "&&": Operator::{
    op: "&&",
    precedence: 15,
    associativity: Associativity::Left,
  },
  "==": Operator::{
    op: "==",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "!=": Operator::{
    op: "!=",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "<": Operator::{ op: "<", precedence: 20, associativity: Associativity::Left },
  ">": Operator::{ op: ">", precedence: 20, associativity: Associativity::Left },
  ">=": Operator::{
    op: ">=",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "<=": Operator::{
    op: "<=",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "in": Operator::{
    op: "in",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "matches": Operator::{
    op: "matches",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "contains": Operator::{
    op: "contains",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "startsWith": Operator::{
    op: "startsWith",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "endsWith": Operator::{
    op: "endsWith",
    precedence: 20,
    associativity: Associativity::Left,
  },
  "..": Operator::{
    op: "..",
    precedence: 25,
    associativity: Associativity::Left,
  },
  "+": Operator::{ op: "+", precedence: 30, associativity: Associativity::Left },
  "-": Operator::{ op: "-", precedence: 30, associativity: Associativity::Left },
  "*": Operator::{ op: "*", precedence: 60, associativity: Associativity::Left },
  "/": Operator::{ op: "/", precedence: 60, associativity: Associativity::Left },
  "%": Operator::{ op: "%", precedence: 60, associativity: Associativity::Left },
  "**": Operator::{
    op: "**",
    precedence: 100,
    associativity: Associativity::Right,
  },
  "^": Operator::{
    op: "^",
    precedence: 100,
    associativity: Associativity::Right,
  },
  "??": Operator::{
    op: "??",
    precedence: 500,
    associativity: Associativity::Left,
  },
}

///|
/// 查找一元操作符
pub fn find_unary_operator(op : String) -> Operator? {
  unary_operators.get(op)
}

///|
/// 查找二元操作符
pub fn find_binary_operator(op : String) -> Operator? {
  binary_operators.get(op)
}

///|
/// 判断是否为比较操作符
pub fn Operator::is_comparison(self : Operator) -> Bool {
  self.op == "<" || self.op == ">" || self.op == ">=" || self.op == "<="
}

///|
/// 判断是否为布尔操作符
pub fn Operator::is_boolean(self : Operator) -> Bool {
  self.op == "and" || self.op == "or" || self.op == "&&" || self.op == "||"
}

///|
/// 判断是否为算术操作符
pub fn Operator::is_arithmetic(self : Operator) -> Bool {
  self.op == "+" ||
  self.op == "-" ||
  self.op == "*" ||
  self.op == "/" ||
  self.op == "%" ||
  self.op == "**" ||
  self.op == "^"
}

///|
/// 判断是否为相等性操作符
pub fn Operator::is_equality(self : Operator) -> Bool {
  self.op == "==" || self.op == "!="
}

///|
/// 判断是否为集合操作符
pub fn Operator::is_collection(self : Operator) -> Bool {
  self.op == "in" ||
  self.op == "contains" ||
  self.op == "matches" ||
  self.op == "startsWith" ||
  self.op == "endsWith"
}

///|
/// 判断是否为范围操作符
pub fn Operator::is_range(self : Operator) -> Bool {
  self.op == ".."
}

///|
/// 判断是否为空值合并操作符
pub fn Operator::is_null_coalescing(self : Operator) -> Bool {
  self.op == "??"
}

///|
/// 比较操作符优先级
pub fn Operator::less_precedence(self : Operator, other : Operator) -> Bool {
  self.precedence < other.precedence
}

///|
/// 比较操作符优先级（相等情况）
pub fn Operator::equal_precedence(self : Operator, other : Operator) -> Bool {
  self.precedence == other.precedence
}

///|
/// 比较操作符优先级（大于情况）
pub fn Operator::greater_precedence(self : Operator, other : Operator) -> Bool {
  self.precedence > other.precedence
}

///|
/// 判断操作符是否允许否定后缀
pub fn Operator::allow_negate_suffix(self : Operator) -> Bool {
  match self.op {
    "contains" => true
    "matches" => true
    "startsWith" => true
    "endsWith" => true
    "in" => true
    _ => false
  }
}

///|
/// 获取所有一元操作符列表
pub fn get_all_unary_operators() -> Array[String] {
  let result = Array::new()
  for key, _ in unary_operators {
    result.push(key)
  }
  result
}

///|
/// 获取所有二元操作符列表
pub fn get_all_binary_operators() -> Array[String] {
  let result = Array::new()
  for key, _ in binary_operators {
    result.push(key)
  }
  result
}

///|
/// 判断字符串是否为一元操作符
pub fn is_unary_operator(op : String) -> Bool {
  unary_operators.contains(op)
}

///|
/// 判断字符串是否为二元操作符
pub fn is_binary_operator(op : String) -> Bool {
  binary_operators.contains(op)
}
