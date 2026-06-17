indirect enum Statement: Equatable {
  case letStatement(name: String, value: Expression)
  case returnStatement(value: Expression)
  case expression(value: Expression)
}

enum Expression: Equatable {
  case identifier(String)
  case integer(Int)
  case boolean(Bool)
  indirect case prefix(op: Token, right: Expression)
  indirect case infix(left: Expression, op: Token, right: Expression)
  indirect case ifExpression(
    condition: Expression, consequence: BlockStatement, alternative: BlockStatement?)
  indirect case function(parameters: [String], body: BlockStatement)
  indirect case call(function: Expression, arguments: [Expression])
}

struct Program: Equatable {
  var statements: [Statement]

  init(statements: [Statement] = []) {
    self.statements = statements
  }
}

struct BlockStatement: Equatable {
  var statements: [Statement]

  init(statements: [Statement] = []) {
    self.statements = statements
  }
}

extension Statement: CustomStringConvertible {
  var description: String {
    switch self {
    case .letStatement(let name, let value): "let \(name) = \(value);"
    case .returnStatement(let value): "return \(value);"
    case .expression(let value): "\(value)"
    }
  }
}

extension Expression: CustomStringConvertible {
  var description: String {
    switch self {
    case .identifier(let name): return name
    case .integer(let value): return String(value)
    case .boolean(let value): return String(value)
    case .prefix(let op, let right): return "(\(op)\(right))"
    case .infix(let left, let op, let right): return "(\(left) \(op) \(right))"
    case .ifExpression(let condition, let consequence, let alternative):
      var s = "if \(condition) \(consequence)"
      if let alt = alternative {
        s += " else \(alt)"
      }
      return s
    case .function(let parameters, let body):
      let params = parameters.joined(separator: ", ")
      return "fn(\(params)) \(body)"
    case .call(let function, let arguments):
      let args = arguments.map(\.description).joined(separator: ", ")
      return "\(function)(\(args))"
    }
  }
}

extension Program: CustomStringConvertible {
  var description: String { statements.map(\.description).joined() }
}

extension BlockStatement: CustomStringConvertible {
  var description: String { "{ \(statements.map(\.description).joined()) }" }
}
