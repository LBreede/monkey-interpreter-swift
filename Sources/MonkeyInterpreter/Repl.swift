enum ReplMode {
  case tokens
  case statements
}

func startRepl(mode: ReplMode = .statements) {
  let prompt = ">> "
  while true {
    print(prompt, terminator: "")
    guard let input = readLine() else { return }

    switch mode {
    case .tokens:
      for token in Lexer(input: input) {
        print(token)
      }
    case .statements:
      var parser = Parser(lexer: Lexer(input: input))
      let program = parser.parseProgram()
      guard parser.errors.isEmpty else {
        for message in parser.errors {
          print("\t" + message)
        }
        continue
      }
      print(program)
    }
  }
}
