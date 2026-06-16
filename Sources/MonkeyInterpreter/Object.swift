enum Object: Equatable, Sendable {
  case integer(Int)
  case boolean(Bool)
  case null
  indirect case `return`(Object)
  case error(message: String)
}

extension Object: CustomStringConvertible {
  var description: String {
    switch self {
    case .integer(let value): "\(value)"
    case .boolean(let value): "\(value)"
    case .null: "null"
    case .`return`(let value): "\(value)"
    case .error(let message): "ERROR: \(message)"
    }
  }
}
