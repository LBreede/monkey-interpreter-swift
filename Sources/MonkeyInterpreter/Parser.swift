enum Precedence: Int, Comparable {
  case lowest, equals, lessGreater, sum, product, prefix, call

  static func < (lhs: Precedence, rhs: Precedence) -> Bool { lhs.rawValue < rhs.rawValue }
}

struct Parser {
  var l: Lexer
  var currToken: Token
  var peekToken: Token
  var errors: [String] = []

  init(lexer: Lexer) {
    l = lexer
    currToken = l.nextToken()
    peekToken = l.nextToken()
  }

  mutating func nextToken() {
    currToken = peekToken
    peekToken = l.nextToken()
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

  mutating func parseStatement() -> Statement? {
    switch currToken {
    case .letKeyword:
      return parseLetStatement()
    case .returnKeyword:
      return parseReturnStatement()
    default:
      return parseExpressionStatement()
    }
  }

  mutating func parseLetStatement() -> Statement? {
    guard case .ident(let name) = peekToken else { return nil }
    nextToken()
    guard expectPeek(.assign) else { return nil }
    nextToken()
    guard let value = parseExpression(.lowest) else { return nil }
    if peekTokenIs(.semicolon) { nextToken() }
    return .`let`(name: name, value: value)
  }

  mutating func parseReturnStatement() -> Statement? {
    nextToken()
    guard let value = parseExpression(.lowest) else { return nil }
    if peekTokenIs(.semicolon) { nextToken() }
    return .`return`(value: value)
  }

  mutating func parseExpressionStatement() -> Statement? {
    guard let value = parseExpression(.lowest) else { return nil }
    if peekTokenIs(.semicolon) { nextToken() }
    return .statement(value: value)
  }

  // MARK: Expressions

  mutating func parseExpression(_ precedence: Precedence) -> Expression? {
    guard var left = parsePrefix() else { return nil }

    while !peekTokenIs(.semicolon) && precedence < peekPrecedence() {
      nextToken()
      guard let next = parseInfix(left) else { return left }
      left = next
    }
    return left
  }

  mutating func parsePrefix() -> Expression? {
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

  mutating func parseInfix(_ left: Expression) -> Expression? {
    switch currToken {
    case .plus, .minus, .slash, .asterisk, .eq, .notEq, .lt, .gt: return parseInfixExpression(left)
    case .lparen: return parseCallExpression(left)
    default: return left
    }
  }

  mutating func parseIntegerLiteral(_ literal: String) -> Expression? {
    guard let value = Int(literal) else {
      errors.append("could not parse \(literal) as integer")
      return nil
    }
    return .integer(value)
  }

  mutating func parsePrefixExpression() -> Expression? {
    let op = currToken
    nextToken()
    guard let right = parseExpression(.prefix) else { return nil }
    return .prefix(op: op, right: right)
  }

  mutating func parseInfixExpression(_ left: Expression) -> Expression? {
    let op = currToken
    let precedence = currPrecedence()
    nextToken()
    guard let right = parseExpression(precedence) else { return nil }
    return .infix(left: left, op: op, right: right)
  }

  mutating func parseGroupedExpression() -> Expression? {
    nextToken()
    let expression = parseExpression(.lowest)
    guard expectPeek(.rparen) else { return nil }
    return expression
  }

  mutating func parseIfExpression() -> Expression? {
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

  mutating func parseBlockStatement() -> BlockStatement {
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

  mutating func parseFunctionExpression() -> Expression? {
    guard expectPeek(.lparen) else { return nil }
    guard let parameters = parseFunctionParameters() else { return nil }
    guard expectPeek(.lbrace) else { return nil }
    let body = parseBlockStatement()
    return .function(parameters: parameters, body: body)
  }

  mutating func parseFunctionParameters() -> [String]? {
    var parameters = [String]()
    if peekTokenIs(.rparen) {
      nextToken()
      return parameters
    }

    nextToken()

    guard case .ident(let ident) = currToken else {
      errors.append("expected function parameter to be identifier, got \(currToken)")
      return nil
    }
    parameters.append(ident)

    while peekTokenIs(.comma) {
      nextToken()
      nextToken()
      guard case .ident(let ident) = currToken else {
        errors.append("expected function parameter to be identifier, got \(currToken)")
        return nil
      }
      parameters.append(ident)
    }

    guard expectPeek(.rparen) else { return nil }

    return parameters
  }

  mutating func parseCallExpression(_ function: Expression) -> Expression? {
    guard let arguments = parseCallArguments() else { return nil }
    return .call(function: function, arguments: arguments)
  }

  mutating func parseCallArguments() -> [Expression]? {
    var args = [Expression]()

    if peekTokenIs(.rparen) {
      nextToken()
      return args
    }

    nextToken()
    guard let expr = parseExpression(.lowest) else { return nil }
    args.append(expr)

    while peekTokenIs(.comma) {
      nextToken()
      nextToken()
      guard let expr = parseExpression(.lowest) else { return nil }
      args.append(expr)
    }

    guard expectPeek(.rparen) else { return nil }

    return args
  }

  // MARK: Precedence

  func precedence(of token: Token) -> Precedence {
    switch token {
    case .eq, .notEq: .equals
    case .lt, .gt: .lessGreater
    case .plus, .minus: .sum
    case .slash, .asterisk: .product
    case .lparen: .call
    default: .lowest
    }
  }

  func peekPrecedence() -> Precedence { precedence(of: peekToken) }
  func currPrecedence() -> Precedence { precedence(of: currToken) }

  // MARK: Token helpers

  func currTokenIs(_ token: Token) -> Bool { currToken == token }
  func peekTokenIs(_ token: Token) -> Bool { peekToken == token }

  mutating func expectPeek(_ token: Token) -> Bool {
    if peekTokenIs(token) {
      nextToken()
      return true
    } else {
      peekError(token)
      return false
    }
  }

  mutating func peekError(_ token: Token) {
    let msg = "expected next token to be \(token), got \(peekToken) instead"
    errors.append(msg)
  }

}
