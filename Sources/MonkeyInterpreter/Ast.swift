indirect enum Statement: Equatable {
  case `let`(name: String, value: Expression)
  case `return`(value: Expression)
  case statement(value: Expression)
}

enum Expression: Equatable {
  case identifier(String)
  case integer(Int)
  case boolean(Bool)
  indirect case prefix(op: Token, right: Expression)
  indirect case infix(left: Expression, op: Token, right: Expression)
}

struct Program: Equatable {
  var statements: [Statement]
}

extension Statement: CustomStringConvertible {
  var description: String {
    switch self {
    case .`let`(let name, let value): "let \(name) = \(value);"
    case .`return`(let value): "return \(value);"
    case .statement(let value): "\(value)"
    }
  }
}

extension Expression: CustomStringConvertible {
  var description: String {
    switch self {
    case .identifier(let name): name
    case .integer(let value): String(value)
    case .boolean(let value): String(value)
    case .prefix(let op, let right): "(\(op)\(right))"
    case .infix(let left, let op, let right): "(\(left) \(op) \(right))"
    }
  }
}

extension Program: CustomStringConvertible {
  var description: String { statements.map(\.description).joined() }
}
