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
  case .prefix(let op, let right): return evalPrefixExpression(op.description, eval(right))
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

func evalPrefixExpression(_ op: String, _ right: Object) -> Object {
  switch op {
  case "!": return evalBangOperatorExpression(right)
  case "-": return evalMinusPrefixOperatorExpression(right)
  default: return nullObject
  }
}

func evalBangOperatorExpression(_ right: Object) -> Object {
  switch right {
  case trueObject: return falseObject
  case falseObject: return trueObject
  case nullObject: return trueObject
  default: return falseObject
  }
}

func evalMinusPrefixOperatorExpression(_ right: Object) -> Object {
  guard case .integer(let value) = right else { return nullObject }
  return .integer(-value)
}
