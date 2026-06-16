import Testing

@testable import MonkeyInterpreter

@Test func evalIntegerExpression() {
  let tests = [
    ("5", 5), ("10", 10), ("-5", -5), ("-10", -10), ("5 + 5 + 5 + 5 - 10", 10),
    ("2 * 2 * 2 * 2 * 2", 32), ("-50 + 100 + -50", 0), ("5 * 2 + 10", 20), ("5 + 2 * 10", 25),
    ("20 + 2 * -10", 0), ("50 / 2 * 2 + 10", 60), ("2 * (5 + 10)", 30), ("3 * 3 * 3 + 10", 37),
    ("3 * (3 * 3) + 10", 37), ("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50),
  ]

  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(testIntegerObject(evaluated, expected))
  }
}

@Test func evalBooleanExpression() {
  let tests = [
    ("true", true),
    ("false", false),
    ("1 < 2", true),
    ("1 > 2", false),
    ("1 < 1", false),
    ("1 > 1", false),
    ("1 == 1", true),
    ("1 != 1", false),
    ("1 == 2", false),
    ("1 != 2", true),
    ("true == true", true),
    ("false == false", true),
    ("true == false", false),
    ("true != false", true),
    ("false != true", true),
    ("(1 < 2) == true", true),
    ("(1 < 2) == false", false),
    ("(1 > 2) == true", false),
    ("(1 > 2) == false", true),
  ]
  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(evaluated == .boolean(expected))
  }
}

@Test func evalReturnsLastStatement() {
  #expect(testEval("5; 10;") == .integer(value: 10))
  #expect(testEval("true; false;") == .boolean(false))
}

@Test func bangOperator() {
  let tests = [
    ("!true", false), ("!false", true), ("!5", false), ("!!true", true), ("!!false", false),
    ("!!5", true),
  ]

  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(evaluated == .boolean(expected))
  }
}

@Test func evalIfElseExpressions() {
  let tests = [
    ("if (true) { 10 }", 10),
    ("if (false) { 10 }", nil),
    ("if (1) { 10 }", 10),
    ("if (1 < 2) { 10 }", 10),
    ("if (1 > 2) { 10 }", nil),
    ("if (1 > 2) { 10 } else { 20 }", 20),
    ("if (1 < 2) { 10 } else { 20 }", 10),
  ]
  for (input, expected) in tests {
    let evaluated = testEval(input)
    if expected == nil {
      #expect(testNullObject(evaluated))
    } else {
      #expect(testIntegerObject(evaluated, expected!))
    }
  }
}

@Test func evalReturnStatements() {
  let tests = [
    ("return 10;", 10),
    ("return 10; 9;", 10),
    ("return 2 * 5; 9;", 10),
    ("9; return 2 * 5; 9;", 10),
    ("if (false) { return 10; } 20;", 20),
    ("if (false) { 10 } else { return 20; } 30;", 20),
    (
      """
      if (10 > 1) {
        if (10 > 1) {
          return 10;
        }
        return 1;
      }
      """, 10
    ),
  ]

  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(testIntegerObject(evaluated, expected))
  }
}

@Test func errorHandling() {
  let tests = [
    ("5 + true;", "type mismatch: INTEGER + BOOLEAN"),
    ("5 + true; 5;", "type mismatch: INTEGER + BOOLEAN"),
    ("-true", "unknown operator: -BOOLEAN"),
    ("true + false;", "unknown operator: BOOLEAN + BOOLEAN"),
    ("5; true + false; 5", "unknown operator: BOOLEAN + BOOLEAN"),
    ("if (10 > 1) { true + false; }", "unknown operator: BOOLEAN + BOOLEAN"),
    (
      """
      if (10 > 1) {
        if (10 > 1) {
          return true + false;
        }

        return 1;
      }
      """,
      "unknown operator: BOOLEAN + BOOLEAN"
    ),
  ]

  for (input, expectedMessage) in tests {
    let evaluated = testEval(input)
    guard case .error(let message) = evaluated else {
      Issue.record("no error object returned. got=\(evaluated)")
      continue
    }
    if message != expectedMessage {
      Issue.record("wrong error message. expected=\(expectedMessage), got=\(message)")
    }
  }
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

func testIntegerObject(_ obj: Object, _ expected: Int) -> Bool {
  guard case .integer(let value) = obj else {
    Issue.record("object is not Integer. got=\(obj)")
    return false
  }
  if value != expected {
    Issue.record("object has wrong value. got=\(value), want=\(expected)")
    return false
  }
  return true
}

func testNullObject(_ obj: Object) -> Bool {
  if obj != nullObject {
    Issue.record("object is not NULL. got=\(obj)")
    return false
  }
  return true
}
