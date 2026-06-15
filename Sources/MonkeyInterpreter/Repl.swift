enum ReplMode {
  case tokens
  case statements
}

private let monkeyFace = #"""
              __,__
     .--.  .-"     "-.  .--.
    / .. \/  .-. .-.  \/ .. \
   | |  '|  /   Y   \  |'  | |
   | \   \  \ 0 | 0 /  /   / |
    \ '- ,\.-"""""""-./, -' /
     ''-' /_   ^ ^   _\ '-''
         |  \._   _./  |
         \   \ '~' /   /
          '._ '-=-' _.'
             '-----'
  """#

func startRepl(mode: ReplMode = .statements) {
  let prompt = ">> "
  while true {
    print(prompt, terminator: "")
    guard let input = readLine() else { return }

    switch mode {
    case .tokens:
      for token in Lexer(input: input) {
        debugPrint(token)
      }
    case .statements:
      var parser = Parser(lexer: Lexer(input: input))
      let program = parser.parseProgram()
      guard parser.errors.isEmpty else {
        printParserErrors(parser.errors)
        continue
      }
      print(program)
    }
  }
}

func printParserErrors(_ errors: [String]) {
  print(monkeyFace)
  print("Woops! We ran into some monkey business here!")
  print(" parser errors:")
  for msg in errors {
    print("\t\(msg)")
  }
}
