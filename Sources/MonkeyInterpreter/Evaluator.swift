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
  case .prefix(let op, let right): return evalPrefixExpression(op, eval(right))
  case .infix(let left, let op, let right): return evalInfixExpression(op, eval(left), eval(right))
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

func evalPrefixExpression(_ op: Token, _ right: Object) -> Object {
  switch op {
  case .bang: return evalBangOperatorExpression(right)
  case .minus: return evalMinusPrefixOperatorExpression(right)
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

func evalInfixExpression(_ op: Token, _ leftObject: Object, _ rightObject: Object) -> Object {
  switch (op, leftObject, rightObject) {
  case (_, .integer(let left), .integer(let right)):
    return evalIntegerInfixExpression(op, left, right)
  case (.eq, _, _): return nativeBoolToBooleanObject(leftObject == rightObject)
  case (.notEq, _, _): return nativeBoolToBooleanObject(leftObject != rightObject)
  default: return nullObject
  }
}

func evalIntegerInfixExpression(_ op: Token, _ left: Int, _ right: Int) -> Object {
  switch op {
  case .plus: return .integer(left + right)
  case .minus: return .integer(left - right)
  case .asterisk: return .integer(left * right)
  case .slash: return .integer(left / right)
  case .lt: return nativeBoolToBooleanObject(left < right)
  case .gt: return nativeBoolToBooleanObject(left > right)
  case .eq: return nativeBoolToBooleanObject(left == right)
  case .notEq: return nativeBoolToBooleanObject(left != right)
  default: return nullObject
  }
}
