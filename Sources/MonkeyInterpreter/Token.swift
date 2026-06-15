enum Token: Equatable {
  case illegal(String)
  case eof
  case ident(String)
  case int(String)
  case assign, plus, minus, bang, asterisk, slash
  case lt, gt
  case eq, notEq
  case comma, semicolon, lparen, rparen, lbrace, rbrace
  case fnKeyword, letKeyword, trueKeyword, falseKeyword, ifKeyword,
    elseKeyword, returnKeyword
}

extension Token: CustomStringConvertible {
  var description: String {
    switch self {
    case .illegal(let s): "illegal(\(s))"
    case .eof: "EOF"
    case .ident(let s): "ident(\(s))"
    case .int(let s): "int(\(s))"
    case .assign: "="
    case .plus: "+"
    case .minus: "-"
    case .bang: "!"
    case .asterisk: "*"
    case .slash: "/"
    case .lt: "<"
    case .gt: ">"
    case .eq: "=="
    case .notEq: "!="
    case .comma: ","
    case .semicolon: ";"
    case .lparen: "("
    case .rparen: ")"
    case .lbrace: "{"
    case .rbrace: "}"
    case .fnKeyword: "fn"
    case .letKeyword: "let"
    case .trueKeyword: "true"
    case .falseKeyword: "false"
    case .ifKeyword: "if"
    case .elseKeyword: "else"
    case .returnKeyword: "return"
    }
  }
}

extension Token: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case .illegal(let s): "illegal(\(String(reflecting: s)))"
    case .eof: "eof"
    case .ident(let s): "ident(\(String(reflecting: s)))"
    case .int(let s): "int(\(String(reflecting: s)))"
    case .assign: "assign"
    case .plus: "plus"
    case .minus: "minus"
    case .bang: "bang"
    case .asterisk: "asterisk"
    case .slash: "slash"
    case .lt: "lt"
    case .gt: "gt"
    case .eq: "eq"
    case .notEq: "notEq"
    case .comma: "comma"
    case .semicolon: "semicolon"
    case .lparen: "lparen"
    case .rparen: "rparen"
    case .lbrace: "lbrace"
    case .rbrace: "rbrace"
    case .fnKeyword: "fnKeyword"
    case .letKeyword: "letKeyword"
    case .trueKeyword: "trueKeyword"
    case .falseKeyword: "falseKeyword"
    case .ifKeyword: "ifKeyword"
    case .elseKeyword: "elseKeyword"
    case .returnKeyword: "returnKeyword"
    }
  }
}

private let keywords: [String: Token] = [
  "fn": .fnKeyword,
  "let": .letKeyword,
  "true": .trueKeyword,
  "false": .falseKeyword,
  "if": .ifKeyword,
  "else": .elseKeyword,
  "return": .returnKeyword,
]

func lookupIdent(_ ident: String) -> Token {
  keywords[ident] ?? .ident(ident)
}
