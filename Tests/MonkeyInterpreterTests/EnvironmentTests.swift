import Testing

@testable import MonkeyInterpreter

@Test func enclosedEnvironmentFallsBackToOuterScope() {
  let outer = Environment()
  outer.set(name: "a", value: .integer(value: 1))

  let enclosed = Environment.enclosed(outer: outer)
  enclosed.set(name: "b", value: .integer(value: 2))

  #expect(testIntegerObject(enclosed.get(name: "a"), 1))
  #expect(testIntegerObject(enclosed.get(name: "b"), 2))
}

@Test func enclosedEnvironmentCanShadowOuterScope() {
  let outer = Environment()
  outer.set(name: "a", value: .integer(value: 1))

  let enclosed = Environment.enclosed(outer: outer)
  enclosed.set(name: "a", value: .integer(value: 2))

  #expect(testIntegerObject(enclosed.get(name: "a"), 2))
  #expect(testIntegerObject(outer.get(name: "a"), 1))
}

private func testIntegerObject(_ object: Object?, _ expected: Int) -> Bool {
  guard case .integer(let value) = object else {
    Issue.record("object is not Integer. got=\(String(describing: object))")
    return false
  }
  if value != expected {
    Issue.record("object has wrong value. got=\(value), want=\(expected)")
    return false
  }
  return true
}
