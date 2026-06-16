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
    var result = "Environment(\(debugBindings))"
    if let outer {
      result += " -> \(outer.debugDescription)"
    }
    return result
  }

  private var debugBindings: String {
    let bindings = store
      .map { "\($0.key): \($0.value)" }
      .sorted()
      .joined(separator: ", ")

    return "[\(bindings)]"
  }
}
