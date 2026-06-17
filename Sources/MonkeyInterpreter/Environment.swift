final class Environment {
  private var store = [String: Object]()
  private let outer: Environment?

  init(outer: Environment? = nil) {
    self.outer = outer
  }

  static func enclosed(outer: Environment) -> Environment {
    Environment(outer: outer)
  }

  func get(name: String) -> Object? {
    store[name] ?? outer?.get(name: name)
  }

  @discardableResult
  func set(name: String, value: Object) -> Object {
    store[name] = value
    return value
  }
}

extension Environment: CustomDebugStringConvertible {
  var debugDescription: String {
    debugDescription(maxDepth: 2)
  }

  fileprivate func debugDescription(maxDepth: Int, includeOuter: Bool = true) -> String {
    let bindings = debugBindings(maxDepth: maxDepth)
    var result = bindings.isEmpty ? "Environment()" : "Environment([\(bindings)])"
    if includeOuter, let outer {
      result += " -> "
      result +=
        maxDepth > 0
        ? outer.debugDescription(maxDepth: maxDepth - 1)
        : "Environment(...)"
    }
    return result
  }

  private func debugBindings(maxDepth: Int) -> String {
    store
      .map { "\($0.key): \(debugDescription(for: $0.value, maxDepth: maxDepth))" }
      .sorted()
      .joined(separator: ", ")
  }

  private func debugDescription(for object: Object, maxDepth: Int) -> String {
    guard maxDepth > 0 else { return object.description }

    switch object {
    case .function(let parameters, let body, let environment):
      var description = "fn(\(parameters.joined(separator: ", "))) \(body)"
      guard environment.outer != nil else { return description }
      description += " <closure: "
      description += environment.debugDescription(maxDepth: maxDepth - 1, includeOuter: false)
      description += ">"
      return description
    default:
      return object.description
    }
  }
}
