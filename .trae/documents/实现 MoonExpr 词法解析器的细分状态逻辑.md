## 总览
- 入口 `Lexer::tokenize` 在 `parser/lexer/lexer.mbt:158`，循环通过 `Lexer::get_transition` 路由到当前状态并执行（`parser/lexer/transition.mbt:35-49`）。
- 状态枚举与架构已存在：`State`（Base/Number/Identifier/Operator/String/Bracket/EOF）在 `parser/lexer/transition.mbt:11-19`，`Transition` trait 在 `parser/lexer/transition.mbt:26-30`。
- 已实现：`BaseTransition` 的初步路由（空白、数字、以点开头的小数、括号）在 `parser/lexer/transition.mbt:52-96`；`NumberTransition` 的完整数字规则在 `parser/lexer/transition.mbt:99-436`；`BracketTransition` 和 `EOFTransition` 在 `parser/lexer/transition.mbt:476-492`、`494-499`。
- 待补齐：`IdentifierTransition`、`OperatorTransition`、`StringTransition` 的完整读取与错误处理，并强化 `BaseTransition` 的路由覆盖。

## 状态路由（BaseTransition 强化）
- 继续跳过空白（保持 `lexer.commit()` 并停在 Base）。
- 若当前字符为字母、`_`、`$`：回退到该字符起点并设置 `state = Identifier`。
- 若为双引号 `"`：回退到引号位置，`state = String`。
- 若为括号类 `()[]{}`：保持现有逻辑，`state = Bracket`。
- 若为数字或 `.` 且可构成小数：保持现有分支进入 `Number`；否则 `.` 作为运算符由 `Operator` 处理。
- 其它非空白、非字母数字、非引号、非括号字符统一路由到 `Operator`，以合并连续操作符。

## 标识符解析（IdentifierTransition）
- 回退到首字符，`lexer.commit()` 固定切片起点。
- 首字符必须是字母或 `_` 或 `$`；后续允许字母/数字/`_`/`$`（使用 `is_alpha_numeric(ch)` 与字面判断）。
- 连续读取直到遇到停止符（空白、括号、引号、操作符字符）；停止时不消费该停止符。
- 发出 `Kind::Ident`，`lexer.state = Base`。

## 操作符解析（OperatorTransition）
- 回退到起点，`lexer.commit()`。
- 读取一段连续的“操作符字符”集合：`+-*/%=&|^!<>?:.,;~@`，排除括号 `()[]{}`、引号、字母数字和下划线，以及空白。
- 支持多字符运算符（例如 `==`, `!=`, `<=`, `>=`, `&&`, `||`, `++`, `--`, `+=`, `->`, `::`, `..` 等），策略为：尽可能吸收同类集合中连续字符；不在此阶段判断语义，仅生成 `Kind::Oper`。
- 发出 `Kind::Oper`，`lexer.state = Base`。

## 字符串解析（StringTransition）
- 回退到引号起点，`lexer.commit()`；消费起始 `"`。
- 直到遇到未转义的结束 `"`：
  - 支持基本转义：`\\`, `\"`, `\n`, `\t`, `\r`（在词法阶段保持原样或规范化为文本；此实现可保留原切片，解析转义可留给语义阶段）。
  - 若在字符串内提前 EOF：抛出 `LexerTransitionError("unterminated string literal")`。
- 发出 `Kind::Str`，`lexer.state = Base`。

## 数字解析已实现的要点复用
- 保持对 `0x/0o/0b`、十进制整数、以点开头的小数、分数与指数、下划线规则的实现（参见 `parser/lexer/transition.mbt:101-436`）。
- Base 与 Number 的边界粘连错误校验已包含（数字后直接连接标识符时抛错）。

## 令牌发出与位置管理
- 所有细分状态在读取前执行 `lexer.rewind_back()` 与 `lexer.commit()`，以确保 `Token.location = {from: start.index, to: current.index}` 与 `Token.value` 的切片正确（`parser/lexer/lexer.mbt:351-366`）。
- 读取完成后统一 `lexer.push_token(Kind::...)` 并将 `lexer.state = State::Base`。
- EOF 情况由各状态在无法继续时推送 `Kind::EOF` 或回到 Base（遵循 `Lexer::eof()` 的统一判定，`parser/lexer/lexer.mbt:130-140`）。

## 边界与错误处理
- 标识符首字符非法、字符串未闭合、数字各进制与下划线位置非法、数字与标识符粘连，均通过 `raise LexerTransitionError(...)`。
- 对变体选择符与 Unicode：沿用现有 `next_char/peek_current/find_next_position` 的一致性处理（测试在 `parser/lexer/lexter_test.mbt` 已覆盖位置推进和 EOF）。

## 测试用例补充（建议）
- 添加入门黑盒测试：
  - 输入：`sum_1 + .5 * func(0xFF, "hi\\n")`。
  - 断言 token 序列：`Ident(sum_1) Oper(+) Num(.5) Oper(*) Ident(func) Bracket(() Num(0xFF) Bracket(,) Str("hi\\n") Bracket()) EOF`。
- 添加运算符聚合测试：`a==b && c!=d || e<=f` 生成分段 `Oper`。
- 添加字符串未闭合错误测试。

## 交付步骤
1. 在 `parser/lexer/transition.mbt` 实现 `IdentifierTransition.execute`、`OperatorTransition.execute`、`StringTransition.execute`，参考现有 `NumberTransition` 的结构与位置管理。
2. 扩展 `BaseTransition::execute` 的路由分支以覆盖标识符、字符串与通用操作符。
3. 在 `parser/lexer/lexter_test.mbt` 增加若干黑盒测试，覆盖标识符、数字、小数/指数、字符串、括号与操作符。
4. 运行测试并根据失败输出微调字符分类边界（如 `.` 在数字与操作符之间的归属）。

## 关键代码定位
- `Lexer::tokenize`：`parser/lexer/lexer.mbt:158`
- `Transition` trait：`parser/lexer/transition.mbt:26-30`
- `get_transition` 路由：`parser/lexer/transition.mbt:35-49`
- `BaseTransition` 现有逻辑：`parser/lexer/transition.mbt:52-96`
- `NumberTransition` 完整实现：`parser/lexer/transition.mbt:99-436`
- `BracketTransition`：`parser/lexer/transition.mbt:476-492`
- `EOFTransition`：`parser/lexer/transition.mbt:494-499`
- `Token` 发出与切片：`parser/lexer/lexer.mbt:351-366`
