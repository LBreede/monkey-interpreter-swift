var trueObject: Object { .boolean(true) }
var falseObject: Object { .boolean(false) }
var nullObject: Object { .null }

func eval(_ program: Program, _ environment: Environment) -> Object {
  var result = nullObject
  for statement in program.statements {
    result = eval(statement, environment)

    if case .returnValue(let value) = result {
      return value
    }
    if isError(result) {
      return result
    }
  }
  return result
}

func eval(_ block: BlockStatement, _ environment: Environment) -> Object {
  var result = nullObject
  for statement in block.statements {
    result = eval(statement, environment)
    if case .returnValue(_) = result {
      return result
    }
    if isError(result) {
      return result
    }
  }
  return result
}

func eval(_ statement: Statement, _ environment: Environment) -> Object {
  switch statement {
  case .letStatement(let name, let value):
    let val = eval(value, environment)
    if isError(val) { return val }
    environment.set(name: name, value: val)
    return nullObject
  case .returnStatement(let value):
    let val = eval(value, environment)
    if isError(val) { return val }
    return .returnValue(value: val)
  case .expression(let value): return eval(value, environment)
  }
}

func eval(_ expression: Expression, _ environment: Environment) -> Object {
  switch expression {
  case .identifier(let name): return evalIdentifier(name, environment)
  case .integer(let value): return .integer(value: value)
  case .boolean(let value): return nativeBoolToBooleanObject(value)
  case .prefix(let op, let right):
    let evaluatedRight = eval(right, environment)
    if isError(evaluatedRight) { return evaluatedRight }
    return evalPrefixExpression(op, evaluatedRight)
  case .infix(let left, let op, let right):
    let evaluatedLeft = eval(left, environment)
    if isError(evaluatedLeft) { return evaluatedLeft }
    let evaluatedRight = eval(right, environment)
    if isError(evaluatedRight) { return evaluatedRight }
    return evalInfixExpression(op, evaluatedLeft, evaluatedRight)
  case .ifExpression(let condition, let consequence, let alternative):
    return evalIfExpression(condition, consequence, alternative, environment)
  case .function(let parameters, let body):
    return .function(parameters: parameters, body: body, environment: environment)
  case .call(let function, let arguments):
    let function = eval(function, environment)
    if isError(function) { return function }
    let args = evalExpressions(arguments, environment)
    if args.count == 1 && isError(args[0]) { return args[0] }
    return applyFunction(function, args)
  }
}

func evalIdentifier(_ name: String, _ environment: Environment) -> Object {
  environment.get(name: name) ?? .error(message: "identifier not found: \(name)")
}

func nativeBoolToBooleanObject(_ value: Bool) -> Object {
  value ? trueObject : falseObject
}

func evalPrefixExpression(_ op: Token, _ right: Object) -> Object {
  switch op {
  case .bang: return evalBangOperatorExpression(right)
  case .minus: return evalMinusPrefixOperatorExpression(right)
  default: return .error(message: "unknown operator: \(op)\(objectType(right))")
  }
}

func evalBangOperatorExpression(_ right: Object) -> Object {
  switch right {
  case .boolean(true): return falseObject
  case .boolean(false): return trueObject
  case .null: return trueObject
  default: return falseObject
  }
}

func evalMinusPrefixOperatorExpression(_ right: Object) -> Object {
  guard case .integer(let value) = right else {
    return .error(message: "unknown operator: -\(objectType(right))")
  }
  return .integer(value: -value)
}

func evalInfixExpression(_ op: Token, _ left: Object, _ right: Object) -> Object {
  switch (op, left, right) {
  case (_, .integer(let left), .integer(let right)):
    return evalIntegerInfixExpression(op, left, right)
  case (.eq, .boolean(let left), .boolean(let right)):
    return nativeBoolToBooleanObject(left == right)
  case (.notEq, .boolean(let left), .boolean(let right)):
    return nativeBoolToBooleanObject(left != right)
  case (.eq, .null, .null):
    return trueObject
  case (.notEq, .null, .null):
    return falseObject
  case (_, _, _) where objectType(left) != objectType(right):
    return .error(message: "type mismatch: \(objectType(left)) \(op) \(objectType(right))")
  default:
    return .error(message: "unknown operator: \(objectType(left)) \(op) \(objectType(right))")
  }
}

func evalIntegerInfixExpression(_ op: Token, _ left: Int, _ right: Int) -> Object {
  switch op {
  case .plus: return .integer(value: left + right)
  case .minus: return .integer(value: left - right)
  case .asterisk: return .integer(value: left * right)
  case .slash: return .integer(value: left / right)
  case .lt: return nativeBoolToBooleanObject(left < right)
  case .gt: return nativeBoolToBooleanObject(left > right)
  case .eq: return nativeBoolToBooleanObject(left == right)
  case .notEq: return nativeBoolToBooleanObject(left != right)
  default: return nullObject
  }
}

func evalIfExpression(
  _ condition: Expression, _ consequence: BlockStatement, _ alternative: BlockStatement?,
  _ environment: Environment
) -> Object {
  let condition = eval(condition, environment)
  if isError(condition) { return condition }

  if isTruthy(condition) {
    return eval(consequence, environment)
  } else if let alternative {
    return eval(alternative, environment)
  } else {
    return nullObject
  }
}

func isTruthy(_ obj: Object) -> Bool {
  switch obj {
  case .null: return false
  case .boolean(let value): return value
  default: return true
  }
}

func objectType(_ object: Object) -> String {
  switch object {
  case .integer: return "INTEGER"
  case .boolean: return "BOOLEAN"
  case .null: return "NULL"
  case .returnValue: return "RETURN"
  case .error: return "ERROR"
  case .function: return "FUNCTION"
  }
}

func isError(_ object: Object) -> Bool {
  if case .error = object { true } else { false }
}

func evalExpressions(_ expressions: [Expression], _ environment: Environment) -> [Object] {
  var result = [Object]()
  for expression in expressions {
    let evaluated = eval(expression, environment)
    if isError(evaluated) { return [evaluated] }
    result.append(evaluated)
  }
  return result
}

func applyFunction(_ function: Object, _ arguments: [Object]) -> Object {
  guard case .function(let parameters, let body, let environment) = function else {
    return .error(message: "not a function: \(objectType(function))")
  }

  guard parameters.count == arguments.count else {
    return .error(message: "wrong number of arguments: want=\(parameters.count), got=\(arguments.count)")
  }

  let extendedEnvironment = extendFunctionEnvironment(
    parameters: parameters,
    arguments: arguments,
    environment: environment
  )
  let evaluated = eval(body, extendedEnvironment)
  return unwrapReturnValue(evaluated)
}

func extendFunctionEnvironment(
  parameters: [String], arguments: [Object], environment: Environment
) -> Environment {
  let extended = Environment.enclosed(outer: environment)
  for (parameter, argument) in zip(parameters, arguments) {
    extended.set(name: parameter, value: argument)
  }
  return extended
}

func unwrapReturnValue(_ object: Object) -> Object {
  if case .returnValue(let value) = object {
    return value
  }
  return object
}
