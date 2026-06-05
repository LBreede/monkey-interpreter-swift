import Testing
@testable import MonkeyInterpreter

@Test
func testNextToken() {
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

    let expectedTokens: [Token] = [
        .letKeyword, .ident("five"), .assign, .int("5"), .semicolon,
        .letKeyword, .ident("ten"), .assign, .int("10"), .semicolon,
        .letKeyword, .ident("add"), .assign, .function, .lparen,
        .ident("x"), .comma, .ident("y"), .rparen, .lbrace, .ident("x"),
        .plus, .ident("y"), .semicolon, .rbrace, .semicolon,
        .letKeyword, .ident("result"), .assign, .ident("add"), .lparen,
        .ident("five"), .comma, .ident("ten"), .rparen, .semicolon,
        .bang, .minus, .slash, .asterisk, .int("5"), .semicolon,
        .int("5"), .lt, .int("10"), .gt, .int("5"), .semicolon,
        .ifKeyword, .lparen, .int("5"), .lt, .int("10"), .rparen, .lbrace,
        .returnKeyword, .trueKeyword, .semicolon,
        .rbrace, .elseKeyword, .lbrace,
        .returnKeyword, .falseKeyword, .semicolon,
        .rbrace,
        .int("10"), .eq, .int("10"), .semicolon,
        .int("10"), .notEq, .int("9"), .semicolon,
        .eof,
    ]

    var lexer = Lexer(input: input)

    for (index, expected) in expectedTokens.enumerated() {
        let actual = lexer.nextToken()

        #expect(
            actual == expected,
            "token[\(index)] expected \(expected), got \(actual)"
        )
    }
}
