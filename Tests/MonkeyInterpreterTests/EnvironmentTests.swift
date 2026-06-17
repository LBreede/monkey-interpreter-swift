import Testing

@testable import MonkeyInterpreter

@Test func environmentFallsBackToOuterScope() {
  let outer = Environment()
  outer.set(name: "a", value: .integer(value: 1))

  let enclosed = Environment.enclosed(outer: outer)
  enclosed.set(name: "b", value: .integer(value: 2))

  #expect(expectIntegerObject(enclosed.get(name: "a"), 1))
  #expect(expectIntegerObject(enclosed.get(name: "b"), 2))
}

@Test func environmentCanShadowOuterScope() {
  let outer = Environment()
  outer.set(name: "a", value: .integer(value: 1))

  let enclosed = Environment.enclosed(outer: outer)
  enclosed.set(name: "a", value: .integer(value: 2))

  #expect(expectIntegerObject(enclosed.get(name: "a"), 2))
  #expect(expectIntegerObject(outer.get(name: "a"), 1))
}

@Test func environmentDebugDescriptionPrintsEmptyEnvironmentCleanly() {
  let environment = Environment()

  #expect(String(reflecting: environment) == "Environment()")
}

@Test func environmentDebugDescriptionShowsClosureEnvironment() {
  let environment = Environment()
  let input = """
    let newAdder = fn(x) {
      fn(y) { x + y };
    };

    let addTwo = newAdder(2);
    """
  var parser = Parser(lexer: Lexer(input: input))
  let program = parser.parseProgram()

  #expect(parser.errors.isEmpty)
  _ = eval(program, environment)

  let debugDescription = String(reflecting: environment)
  #expect(
    debugDescription.contains(
      "addTwo: fn(y) { (x + y) } <closure: Environment([x: 2])>"
    ))
}

private func expectIntegerObject(_ object: Object?, _ expected: Int) -> Bool {
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
