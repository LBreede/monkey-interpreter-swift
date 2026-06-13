enum Token: Equatable {
  case illegal(String)
  case eof
  case ident(String)
  case int(String)
  case assign, plus, minus, bang, asterisk, slash
  case lt, gt
  case eq, notEq
  case comma, semicolon, lparen, rparen, lbrace, rbrace
  case function, letKeyword, trueKeyword, falseKeyword, ifKeyword,
    elseKeyword, returnKeyword
}

// extension Token: CustomStringConvertible {
//   var description: String {
//     switch self {
//     case .illegal(let s): "ILLEGAL(\(s))"
//     case .eof: "EOF"
//     case .ident(let s): "IDENT(\(s))"
//     case .int(let s): "INT(\(s))"
//     case .assign: "="
//     case .plus: "+"
//     case .minus: "-"
//     case .bang: "!"
//     case .asterisk: "*"
//     case .slash: "/"
//     case .lt: "<"
//     case .gt: ">"
//     case .eq: "=="
//     case .notEq: "!="
//     case .comma: ","
//     case .semicolon: ";"
//     case .lparen: "("
//     case .rparen: ")"
//     case .lbrace: "{"
//     case .rbrace: "}"
//     case .function: "fn"
//     case .letKeyword: "let"
//     case .trueKeyword: "true"
//     case .falseKeyword: "false"
//     case .ifKeyword: "if"
//     case .elseKeyword: "else"
//     case .returnKeyword: "return"
//     }
//   }
// }

private let keywords: [String: Token] = [
  "fn": .function,
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
