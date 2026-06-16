enum Object: Equatable {
  case integer(Int)
  case boolean(Bool)
  case null
}

extension Object: CustomStringConvertible {
  var description: String {
    switch self {
    case .integer(let value): "\(value)"
    case .boolean(let value): "\(value)"
    case .null: "null"
    }
  }
}
