import Testing

@testable import MonkeyInterpreter

@Test
func letStatements() throws {
  let input = """
    let x = 5;
    let y = 10;
    let foobar = 838383;
    """
  var parser = Parser(lexer: Lexer(input: input))
  let program = parser.parseProgram()
  checkParserErrors(parser)

  try #require(program.statements.count == 3)

  let expectedNames = ["x", "y", "foobar"]

  for (i, name) in expectedNames.enumerated() {
    expectLetStatement(program.statements[i], name: name)
  }
}

@Test
func returnStatements() throws {
  let input = """
    return 5;
    return 10;
    return 993322;
    """
  var parser = Parser(lexer: Lexer(input: input))
  let program = parser.parseProgram()
  checkParserErrors(parser)

  try #require(program.statements.count == 3)

  for statement in program.statements {
    guard case .`return`(_) = statement else {
      Issue.record("expected a return statement, got \(statement)")
      continue
    }
  }
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
