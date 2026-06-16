import Testing

@testable import MonkeyInterpreter

@Test func evaluatorEvaluatesIntegerExpressions() {
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

@Test func evaluatorEvaluatesBooleanExpressions() {
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
    #expect(testBooleanObject(evaluated, expected))
  }
}

@Test func evaluatorReturnsLastStatement() {
  #expect(testIntegerObject(testEval("5; 10;"), 10))
  #expect(testBooleanObject(testEval("true; false;"), false))
}

@Test func evaluatorEvaluatesBangOperator() {
  let tests = [
    ("!true", false), ("!false", true), ("!5", false), ("!!true", true), ("!!false", false),
    ("!!5", true),
  ]

  for (input, expected) in tests {
    let evaluated = testEval(input)
    #expect(testBooleanObject(evaluated, expected))
  }
}

@Test func evaluatorEvaluatesIfElseExpressions() {
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

@Test func evaluatorEvaluatesReturnStatements() {
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

@Test func evaluatorPropagatesErrors() {
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
    ("foobar", "identifier not found: foobar"),
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

@Test func evaluatorEvaluatesLetStatements() {
  let tests = [
    ("let a = 5; a;", 5),
    ("let a = 5 * 5; a;", 25),
    ("let a = 5; let b = a; b;", 5),
    ("let a = 5; let b = a; let c = a + b + 5; c;", 15),
  ]
  for (input, expected) in tests {
    #expect(testIntegerObject(testEval(input), expected))
  }
}

@Test func evaluatorEvaluatesFunctionObjects() {
  let input = "fn(x) { x + 2; };"

  let evaluated = testEval(input)
  guard case .function(let parameters, let body, _) = evaluated else {
    Issue.record("object is not a Function. got=\(evaluated)")
    return
  }

  guard parameters.count == 1 else {
    Issue.record("function has wrong parameters. Parameters=\(parameters)")
    return
  }

  guard parameters[0] == "x" else {
    Issue.record("parameter is not 'x'. got=\(parameters[0])")
    return
  }

  guard body.statements.count == 1 else {
    Issue.record("function body has wrong number of statements. got=\(body.statements.count)")
    return
  }

  let expectedBody = "(x + 2)"
  if body.statements.first?.description != expectedBody {
    Issue.record("body is not \(expectedBody). got=\(body)")
  }
}

@Test func evaluatorAppliesFunctions() {
  let tests = [
    ("let identity = fn(x) { x; }; identity(5);", 5),
    ("let identity = fn(x) { return x; }; identity(5);", 5),
    ("let double = fn(x) { x * 2; }; double(5);", 10),
    ("let add = fn(x, y) { x + y; }; add(5, 5);", 10),
    ("let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20),
    ("fn(x) { x; }(5)", 5),
  ]
  for (input, expected) in tests {
    #expect(testIntegerObject(testEval(input), expected))
  }
}

@Test func evaluatorEvaluatesClosures() {
  let input = """
    let newAdder = fn(x) {
      fn(y) { x + y };
    };

    let addTwo = newAdder(2);
    addTwo(2);
    """

  #expect(testIntegerObject(testEval(input), 4))
}

func testEval(_ input: String, sourceLocation: SourceLocation = #_sourceLocation) -> Object {
  var parser = Parser(lexer: Lexer(input: input))
  let program = parser.parseProgram()
  let environment = Environment()
  guard parser.errors.isEmpty else {
    for error in parser.errors {
      Issue.record("parser error: \(error)", sourceLocation: sourceLocation)
    }
    return .null
  }
  return eval(program, environment)
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

func testBooleanObject(_ obj: Object, _ expected: Bool) -> Bool {
  guard case .boolean(let value) = obj else {
    Issue.record("object is not Boolean. got=\(obj)")
    return false
  }
  if value != expected {
    Issue.record("object has wrong value. got=\(value), want=\(expected)")
    return false
  }
  return true
}

func testNullObject(_ object: Object) -> Bool {
  switch object {
  case .null:
    return true
  default:
    Issue.record("object is not NULL. got=\(object)")
    return false
  }
}
