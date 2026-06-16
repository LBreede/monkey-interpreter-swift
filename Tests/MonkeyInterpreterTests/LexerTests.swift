import Testing

@testable import MonkeyInterpreter

@Test
func lexerTokenizesSingleCharacterTokens() {
  expectTokens(
    input: "=+(){},;-!/*<>",
    [
      .assign, .plus, .lparen, .rparen, .lbrace, .rbrace,
      .comma, .semicolon, .minus, .bang, .slash, .asterisk, .lt, .gt,
      .eof,
    ]
  )
}

@Test
func lexerTokenizesTwoCharacterOperators() {
  expectTokens(
    input: "10 == 10; 10 != 9;",
    [
      .int("10"), .eq, .int("10"), .semicolon,
      .int("10"), .notEq, .int("9"), .semicolon,
      .eof,
    ]
  )
}

@Test
func lexerTokenizesKeywordsAndIdentifiers() {
  expectTokens(
    input: "fn let true false if else return foobar _name",
    [
      .fnKeyword, .letKeyword, .trueKeyword, .falseKeyword, .ifKeyword,
      .elseKeyword, .returnKeyword, .ident("foobar"), .ident("_name"),
      .eof,
    ]
  )
}

@Test
func lexerSkipsWhitespace() {
  expectTokens(
    input: "let\tfive\n=\r\n5;",
    [.letKeyword, .ident("five"), .assign, .int("5"), .semicolon, .eof]
  )
}

@Test
func lexerTokenizesIllegalCharacters() {
  expectTokens(input: "@", [.illegal("@"), .eof])
}

@Test
func lexerSequenceConformanceOmitsEOF() {
  let tokens = Array(Lexer(input: "let five = 5;"))

  #expect(tokens == [.letKeyword, .ident("five"), .assign, .int("5"), .semicolon])
}

@Test
func lexerNextTokenReturnsEOFRepeatedlyAfterInputEnds() {
  var lexer = Lexer(input: "")

  #expect(lexer.nextToken() == .eof)
  #expect(lexer.nextToken() == .eof)
}

@Test
func lexerTokenizesMonkeyBookExample() {
  let input = """
    let five = 5;
    let ten = 10;

    let add = fn(x, y) {
      x + y;
    };

    let result = add(five, ten);
    !-/*5;
    5 < 10 > 5;

    if (5 < 10) {
        return true;
    } else {
        return false;
    }

    10 == 10;
    10 != 9;
    """

  expectTokens(
    input: input,
    [
      .letKeyword, .ident("five"), .assign, .int("5"), .semicolon,
      .letKeyword, .ident("ten"), .assign, .int("10"), .semicolon,
      .letKeyword, .ident("add"), .assign, .fnKeyword, .lparen,
      .ident("x"), .comma, .ident("y"), .rparen, .lbrace, .ident("x"),
      .plus, .ident("y"), .semicolon, .rbrace, .semicolon,
      .letKeyword, .ident("result"), .assign, .ident("add"), .lparen,
      .ident("five"), .comma, .ident("ten"), .rparen, .semicolon,
      .bang, .minus, .slash, .asterisk, .int("5"), .semicolon,
      .int("5"), .lt, .int("10"), .gt, .int("5"), .semicolon,
      .ifKeyword, .lparen, .int("5"), .lt, .int("10"), .rparen,
      .lbrace, .returnKeyword, .trueKeyword, .semicolon,
      .rbrace, .elseKeyword, .lbrace,
      .returnKeyword, .falseKeyword, .semicolon,
      .rbrace,
      .int("10"), .eq, .int("10"), .semicolon,
      .int("10"), .notEq, .int("9"), .semicolon,
      .eof,
    ]
  )
}

private func expectTokens(input: String, _ expectedTokens: [Token]) {
  var lexer = Lexer(input: input)

  for (index, expected) in expectedTokens.enumerated() {
    let actual = lexer.nextToken()

    #expect(
      actual == expected,
      "token[\(index)] expected \(expected), got \(actual)"
    )
  }
}
