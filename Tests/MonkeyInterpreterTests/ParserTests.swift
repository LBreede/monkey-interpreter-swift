import Testing

@testable import MonkeyInterpreter

@Test func letStatements() throws {
  let input = """
    let x = 5;
    let y = 10;
    let foobar = 838383;
    """
  let program = parseProgram(input)
  try #require(program.statements.count == 3)
  let expectedNames = ["x", "y", "foobar"]
  for (i, name) in expectedNames.enumerated() {
    expectLetStatement(program.statements[i], name: name)
  }
}

@Test func returnStatements() throws {
  let input = """
    return 5;
    return 10;
    return 993322;
    """
  let program = parseProgram(input)
  try #require(program.statements.count == 3)
  for statement in program.statements {
    guard case .`return`(_) = statement else {
      Issue.record("expected a return statement, got \(statement)")
      continue
    }
  }
}

@Test func identifierExpressions() {
  #expect(soleExpression("foobar;") == .identifier("foobar"))
}

@Test func integerLiteralExpressions() {
  #expect(soleExpression("5;") == .integer(5))
}

@Test func booleanExpressions() {
  #expect(soleExpression("true;") == .boolean(true))
  #expect(soleExpression("false;") == .boolean(false))
}

@Test func prefixExpressions() {
  #expect(soleExpression("!5;") == .prefix(op: .bang, right: .integer(5)))
  #expect(soleExpression("-15;") == .prefix(op: .minus, right: .integer(15)))
  #expect(soleExpression("!true;") == .prefix(op: .bang, right: .boolean(true)))
  #expect(soleExpression("!false;") == .prefix(op: .bang, right: .boolean(false)))
}

@Test func infixExpressions() {
  let operators: [(String, Token)] = [
    ("+", .plus), ("-", .minus), ("*", .asterisk), ("/", .slash),
    (">", .gt), ("<", .lt), ("==", .eq), ("!=", .notEq),
  ]
  for (symbol, op) in operators {
    #expect(
      soleExpression("5 \(symbol) 5;") == .infix(left: .integer(5), op: op, right: .integer(5)),
      "operator: \(symbol)")
  }
}

@Test func operatorPrecedenceParsing() {
  let cases = [
    ("-a * b", "((-a) * b)"),
    ("!-a", "(!(-a))"),
    ("a + b + c", "((a + b) + c)"),
    ("a + b - c", "((a + b) - c)"),
    ("a * b * c", "((a * b) * c)"),
    ("a * b / c", "((a * b) / c)"),
    ("a + b / c", "(a + (b / c))"),
    ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
    ("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"),
    ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
    ("5 > 4 != 3 > 4", "((5 > 4) != (3 > 4))"),
    ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
    ("true", "true"),
    ("false", "false"),
    ("3 > 5 == false", "((3 > 5) == false)"),
    ("3 < 5 == true", "((3 < 5) == true)"),
    ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
    ("(5 + 5) * 2", "((5 + 5) * 2)"),
    ("2 / (5 + 5)", "(2 / (5 + 5))"),
    ("-(5 + 5)", "(-(5 + 5))"),
    ("!(true == true)", "(!(true == true))"),
  ]
  for (input, expected) in cases {
    #expect(parseProgram(input).description == expected, "input: \(input)")
  }
}

@Test func ifExpressions() throws {
  guard
    case .`if`(let condition, let consequence, let alternative) = soleExpression("if (x < y) { x }")
  else {
    Issue.record("expected if expression")
    return
  }

  #expect(condition == .infix(left: .identifier("x"), op: .lt, right: .identifier("y")))
  #expect(consequence.statements.count == 1)
  #expect(consequence.statements.first == .statement(value: .identifier("x")))
  #expect(alternative == nil)
}

@Test func ifElseExpressions() throws {
  guard
    case .`if`(let condition, let consequence, let alternative) = soleExpression(
      "if (x < y) { x } else { y }")
  else {
    Issue.record("expected if-else expression")
    return
  }

  #expect(condition == .infix(left: .identifier("x"), op: .lt, right: .identifier("y")))
  #expect(consequence.statements.count == 1)
  #expect(consequence.statements.first == .statement(value: .identifier("x")))
  #expect(alternative?.statements.count == 1)
  #expect(alternative?.statements.first == .statement(value: .identifier("y")))
}

func parseProgram(_ input: String, sourceLocation: SourceLocation = #_sourceLocation) -> Program {
  var parser = Parser(lexer: Lexer(input: input))
  let program = parser.parseProgram()
  checkParserErrors(parser, sourceLocation: sourceLocation)
  return program
}

func expectLetStatement(
  _ statement: Statement, name: String, sourceLocation: SourceLocation = #_sourceLocation
) {
  guard case .`let`(let boundName, _) = statement else {
    Issue.record("expected a let statement, got \(statement)", sourceLocation: sourceLocation)
    return
  }
  #expect(boundName == name, sourceLocation: sourceLocation)
}

func checkParserErrors(_ parser: Parser, sourceLocation: SourceLocation = #_sourceLocation) {
  for message in parser.errors {
    Issue.record("parser error: \(message)", sourceLocation: sourceLocation)
  }
}

func soleExpression(_ input: String, sourceLocation: SourceLocation = #_sourceLocation)
  -> Expression?
{
  let program = parseProgram(input, sourceLocation: sourceLocation)
  guard program.statements.count == 1 else {
    Issue.record(
      "expected 1 statement, got \(program.statements.count)", sourceLocation: sourceLocation)
    return nil
  }
  guard case .statement(let expression) = program.statements[0] else {
    Issue.record(
      "not an expression statement: \(program.statements[0])", sourceLocation: sourceLocation)
    return nil
  }
  return expression
}
