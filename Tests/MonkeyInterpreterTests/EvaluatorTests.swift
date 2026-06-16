import Testing

@testable import MonkeyInterpreter

@Test func evalIntegerExpression() {
  let tests = [("5", 5), ("10", 10)]

  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(evaluated == .integer(expected))
  }
}

@Test func evalBooleanExpression() {
  let tests = [("true", true), ("false", false)]
  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(evaluated == .boolean(expected))
  }
}

@Test func evalReturnsLastStatement() {
  #expect(testEval("5; 10;") == .integer(10))
  #expect(testEval("true; false;") == .boolean(false))
}

func testEval(_ input: String, sourceLocation: SourceLocation = #_sourceLocation) -> Object {
  var parser = Parser(lexer: Lexer(input: input))
  let program = parser.parseProgram()
  guard parser.errors.isEmpty else {
    for error in parser.errors {
      Issue.record("parser error: \(error)", sourceLocation: sourceLocation)
    }
    return .null
  }
  return eval(program)
}
