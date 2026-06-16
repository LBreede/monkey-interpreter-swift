enum Object: Equatable, Sendable {
  case integer(value: Int)
  case boolean(Bool)
  case null
  indirect case returnValue(value: Object)
  case error(message: String)
}

extension Object: CustomStringConvertible {
  var description: String {
    switch self {
    case .integer(let value): "\(value)"
    case .boolean(let value): "\(value)"
    case .null: "null"
    case .returnValue(let value): "\(value)"
    case .error(let message): "ERROR: \(message)"
    }
  }
}
