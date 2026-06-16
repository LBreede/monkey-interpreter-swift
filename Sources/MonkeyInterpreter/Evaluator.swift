let trueObject: Object = .boolean(true)
let falseObject: Object = .boolean(false)
let nullObject: Object = .null

func eval(_ program: Program) -> Object {
  return evalStatements(program.statements)
}

func eval(_ block: BlockStatement) -> Object { return nullObject }

func eval(_ statement: Statement) -> Object {
  switch statement {
  case .expression(let expression): return eval(expression)
  default: return nullObject
  }
}

func eval(_ expression: Expression) -> Object {
  switch expression {
  case .integer(let value): return .integer(value)
  case .boolean(let value): return nativeBoolToBooleanObject(value)
  default: return nullObject
  }
}

func evalStatements(_ statements: [Statement]) -> Object {
  var result = nullObject

  for statement in statements {
    result = eval(statement)
  }

  return result
}

func nativeBoolToBooleanObject(_ value: Bool) -> Object {
  value ? trueObject : falseObject
}
