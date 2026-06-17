enum Object {
  case integer(value: Int)
  case boolean(Bool)
  case null
  indirect case returnValue(value: Object)
  case error(message: String)
  indirect case function(parameters: [String], body: BlockStatement, environment: Environment)
}

extension Object {
  /// The Monkey object type name used in evaluator error messages.
  ///
  /// These strings intentionally match the names from _Writing an Interpreter
  /// in Go_ because evaluator error tests assert against the book's output.
  var typeDescription: String {
    switch self {
    case .integer: "INTEGER"
    case .boolean: "BOOLEAN"
    case .null: "NULL"
    case .returnValue: "RETURN"
    case .error: "ERROR"
    case .function: "FUNCTION"
    }
  }
}

extension Object: CustomStringConvertible {
  var description: String {
    switch self {
    case .integer(let value): "\(value)"
    case .boolean(let value): "\(value)"
    case .null: "null"
    case .returnValue(let value): "\(value)"
    case .error(let message): "ERROR: \(message)"
    case .function(let parameters, let body, _):
      "fn(\(parameters.joined(separator: ", "))) \(body)"
    }
  }
}
