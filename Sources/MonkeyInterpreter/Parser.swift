enum Precedence: Int, Comparable {
  case lowest, equals, lessGreater, sum, product, prefix, call

  static func < (lhs: Precedence, rhs: Precedence) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct Parser {
  var lexer: Lexer
  var currToken: Token
  var peekToken: Token
  var errors: [String] = []

  init(lexer: Lexer) {
    self.lexer = lexer
    currToken = self.lexer.nextToken()
    peekToken = self.lexer.nextToken()
  }

  private mutating func nextToken() {
    currToken = peekToken
    peekToken = lexer.nextToken()
  }

  mutating func parseProgram() -> Program {
    var program = Program(statements: [])
    while currToken != .eof {
      if let stmt = parseStatement() {
        program.statements.append(stmt)
      }
      nextToken()
    }
    return program
  }

  // MARK: Statements

  private mutating func parseStatement() -> Statement? {
    switch currToken {
    case .letKeyword:
      return parseLetStatement()
    case .returnKeyword:
      return parseReturnStatement()
    default:
      return parseExpressionStatement()
    }
  }

  private mutating func parseLetStatement() -> Statement? {
    guard case .ident(let name) = peekToken else { return nil }
    nextToken()
    guard expectPeek(.assign) else { return nil }
    nextToken()
    guard let value = parseExpression(.lowest) else { return nil }
    if peekTokenIs(.semicolon) { nextToken() }
    return .`let`(name: name, value: value)
  }

  private mutating func parseReturnStatement() -> Statement? {
    nextToken()
    guard let value = parseExpression(.lowest) else { return nil }
    if peekTokenIs(.semicolon) { nextToken() }
    return .`return`(value: value)
  }

  private mutating func parseExpressionStatement() -> Statement? {
    guard let value = parseExpression(.lowest) else { return nil }
    if peekTokenIs(.semicolon) { nextToken() }
    return .statement(value: value)
  }

  // MARK: Expressions

  private mutating func parseExpression(_ precedence: Precedence) -> Expression? {
    guard var left = parsePrefix() else { return nil }

    while !peekTokenIs(.semicolon) && precedence < peekPrecedence() {
      nextToken()
      guard let next = parseInfix(left) else { return left }
      left = next
    }
    return left
  }

  private mutating func parsePrefix() -> Expression? {
    switch currToken {
    case .ident(let name): return .identifier(name)
    case .int(let literal): return parseIntegerLiteral(literal)
    case .bang, .minus: return parsePrefixExpression()
    case .trueKeyword, .falseKeyword: return .boolean(currTokenIs(.trueKeyword))
    case .lparen: return parseGroupedExpression()
    case .ifKeyword: return parseIfExpression()
    case .function: return parseFunctionExpression()
    default:
      errors.append("no prefix parse function for \(currToken) found")
      return nil
    }
  }

  private mutating func parseInfix(_ left: Expression) -> Expression? {
    switch currToken {
    case .plus, .minus, .slash, .asterisk, .eq, .notEq, .lt, .gt: return parseInfixExpression(left)
    case .lparen: return parseCallExpression(left)
    default: return left
    }
  }

  private mutating func parseIntegerLiteral(_ literal: String) -> Expression? {
    guard let value = Int(literal) else {
      errors.append("could not parse \(literal) as integer")
      return nil
    }
    return .integer(value)
  }

  private mutating func parsePrefixExpression() -> Expression? {
    let op = currToken
    nextToken()
    guard let right = parseExpression(.prefix) else { return nil }
    return .prefix(op: op, right: right)
  }

  private mutating func parseInfixExpression(_ left: Expression) -> Expression? {
    let op = currToken
    let precedence = currPrecedence()
    nextToken()
    guard let right = parseExpression(precedence) else { return nil }
    return .infix(left: left, op: op, right: right)
  }

  private mutating func parseGroupedExpression() -> Expression? {
    nextToken()
    let expression = parseExpression(.lowest)
    guard expectPeek(.rparen) else { return nil }
    return expression
  }

  private mutating func parseIfExpression() -> Expression? {
    guard expectPeek(.lparen) else { return nil }
    nextToken()
    guard let condition = parseExpression(.lowest) else { return nil }
    guard expectPeek(.rparen) else { return nil }
    guard expectPeek(.lbrace) else { return nil }
    let consequence = parseBlockStatement()

    var alternative: BlockStatement?
    if peekTokenIs(.elseKeyword) {
      nextToken()
      guard expectPeek(.lbrace) else { return nil }
      alternative = parseBlockStatement()
    }

    return .`if`(condition: condition, consequence: consequence, alternative: alternative)
  }

  private mutating func parseBlockStatement() -> BlockStatement {
    var block = BlockStatement(statements: [])

    nextToken()
    while !currTokenIs(.rbrace) && !currTokenIs(.eof) {
      if let statement = parseStatement() {
        block.statements.append(statement)
      }
      nextToken()
    }

    return block
  }

  private mutating func parseFunctionExpression() -> Expression? {
    guard expectPeek(.lparen) else { return nil }
    guard let parameters = parseFunctionParameters() else { return nil }
    guard expectPeek(.lbrace) else { return nil }
    let body = parseBlockStatement()
    return .function(parameters: parameters, body: body)
  }

  private mutating func parseFunctionParameters() -> [String]? {
    parseDelimitedList(end: .rparen) { parser in
      parser.parseFunctionParameter()
    }
  }

  private mutating func parseFunctionParameter() -> String? {
    guard case .ident(let ident) = currToken else {
      errors.append("expected function parameter to be identifier, got \(currToken)")
      return nil
    }
    return ident
  }

  private mutating func parseCallExpression(_ function: Expression) -> Expression? {
    guard let arguments = parseCallArguments() else { return nil }
    return .call(function: function, arguments: arguments)
  }

  private mutating func parseCallArguments() -> [Expression]? {
    parseDelimitedList(end: .rparen) { parser in
      parser.parseExpression(.lowest)
    }
  }

  private mutating func parseDelimitedList<T>(
    end: Token, parseElement: (inout Parser) -> T?
  ) -> [T]? {
    var elements = [T]()
    if peekTokenIs(end) {
      nextToken()
      return elements
    }

    nextToken()
    guard let first = parseElement(&self) else { return nil }
    elements.append(first)

    while peekTokenIs(.comma) {
      nextToken()
      nextToken()
      guard let element = parseElement(&self) else { return nil }
      elements.append(element)
    }

    guard expectPeek(end) else { return nil }
    return elements
  }

  // MARK: Precedence

  private func precedence(of token: Token) -> Precedence {
    switch token {
    case .eq, .notEq: .equals
    case .lt, .gt: .lessGreater
    case .plus, .minus: .sum
    case .slash, .asterisk: .product
    case .lparen: .call
    default: .lowest
    }
  }

  private func peekPrecedence() -> Precedence { precedence(of: peekToken) }
  private func currPrecedence() -> Precedence { precedence(of: currToken) }

  // MARK: Token helpers

  private func currTokenIs(_ token: Token) -> Bool { currToken == token }
  private func peekTokenIs(_ token: Token) -> Bool { peekToken == token }

  private mutating func expectPeek(_ token: Token) -> Bool {
    if peekTokenIs(token) {
      nextToken()
      return true
    } else {
      peekError(token)
      return false
    }
  }

  private mutating func peekError(_ token: Token) {
    let msg = "expected next token to be \(token), got \(peekToken) instead"
    errors.append(msg)
  }

}
