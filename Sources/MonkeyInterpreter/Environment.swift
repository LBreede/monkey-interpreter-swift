final class Environment {
  private var store = [String: Object]()

  func get(name: String) -> Object? { store[name] }

  @discardableResult
  func set(name: String, value: Object) -> Object {
    store[name] = value
    return value
  }
}
