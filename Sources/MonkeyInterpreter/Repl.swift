func startRepl() {
  let prompt = ">> "
  while true {
    print(prompt, terminator: "")
    guard let input = readLine() else { return }
    for token in Lexer(input: input) {
      print(token)
    }
  }
}
