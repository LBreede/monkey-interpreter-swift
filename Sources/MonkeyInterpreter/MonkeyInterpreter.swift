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

extension Token: CustomStringConvertible {
    var description: String {
        switch self {
        case .illegal(let s): "ILLEGAL(\(s))"
        case .eof: "EOF"
        case .ident(let s): "IDENT(\(s))"
        case .int(let s): "INT(\(s))"
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
        case .function: "fn"
        case .letKeyword: "let"
        case .trueKeyword: "true"
        case .falseKeyword: "false"
        case .ifKeyword: "if"
        case .elseKeyword: "else"
        case .returnKeyword: "return"
        }
    }
}

let keywords: [String: Token] = [
    "fn": .function,
    "let": .letKeyword,
    "true": .trueKeyword,
    "false": .falseKeyword,
    "if": .ifKeyword,
    "else": .elseKeyword,
    "return": .returnKeyword,
]

func lookupIdent(_ ident: String) -> Token { keywords[ident] ?? .ident(ident) }

struct Lexer {
    let input: [Character]
    var position: Int = 0
    var readPosition: Int = 0
    var ch: Character? = nil

    init(input: String) {
        self.input = Array(input)
        self.readChar()
    }

    mutating func readChar() {
        ch = readPosition >= input.count ? nil : input[readPosition]
        position = readPosition
        readPosition += 1
    }

    func peekChar() -> Character? {
        readPosition >= input.count ? nil : input[readPosition]
    }

    mutating func nextToken() -> Token {
        skipWhitespace()

        guard let c = ch else { return .eof }

        var tok: Token
        switch c {
        case "!":
            if peekChar() == "=" {
                readChar()
                tok = .notEq
            } else {
                tok = .bang
            }
        case "(": tok = .lparen
        case ")": tok = .rparen
        case "*": tok = .asterisk
        case "+": tok = .plus
        case ",": tok = .comma
        case "-": tok = .minus
        case "/": tok = .slash
        case ";": tok = .semicolon
        case "<": tok = .lt
        case "=":
            if peekChar() == "=" {
                readChar()
                tok = .eq
            } else {
                tok = .assign
            }
        case ">": tok = .gt
        case "{": tok = .lbrace
        case "}": tok = .rbrace
        case "a"..."z", "A"..."Z", "_":
            return lookupIdent(readIdentifier())
        case "0"..."9":
            return .int(readNumber())
        default:
            tok = .illegal(String(c))
        }
        readChar()
        return tok
    }

    mutating func skipWhitespace() {
        while let c = ch, c.isWhitespace {
            readChar()
        }
    }

    mutating func readIdentifier() -> String {
        let start = position
        while let c = ch,
            ("a"..."z").contains(c) || ("A"..."Z").contains(c) || c == "_"
        {
            readChar()
        }
        return String(input[start..<position])
    }

    mutating func readNumber() -> String {
        let start = position
        while let c = ch, ("0"..."9").contains(c) {
            readChar()
        }
        return String(input[start..<position])
    }

}

extension Lexer: Sequence, IteratorProtocol {
    mutating func next() -> Token? {
        let tok = nextToken()
        return tok == .eof ? nil : tok
    }
}

func start() {
    let prompt = ">> "
    while true {
        print(prompt, terminator: "")
        guard let input = readLine() else { return }  // exit on EOF
        for token in Lexer(input: input) {
            print(token)
        }
    }
}
