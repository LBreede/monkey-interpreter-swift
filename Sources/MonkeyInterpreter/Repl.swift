enum ReplMode {
  case tokens
  case ast
  case evaluator
}

struct ReplOptions {
  var mode: ReplMode
  var debug: Bool

  init(mode: ReplMode = .evaluator, debug: Bool = false) {
    self.mode = mode
    self.debug = debug
  }

  init(arguments: [String]) {
    mode =
      if arguments.contains("--tokens") {
        .tokens
      } else if arguments.contains("--ast") {
        .ast
      } else {
        .evaluator
      }
    debug = arguments.contains("--debug")
  }
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

func startRepl(options: ReplOptions = ReplOptions()) {
  let prompt = ">> "
  let environment = Environment()

  while true {
    print(prompt, terminator: "")
    guard let input = readLine() else { return }

    switch options.mode {
    case .tokens:
      for token in Lexer(input: input) {
        debugPrint(token)
      }
    case .ast:
      var parser = Parser(lexer: Lexer(input: input))
      let program = parser.parseProgram()
      guard parser.errors.isEmpty else {
        printParserErrors(parser.errors)
        continue
      }
      print(program)
    case .evaluator:
      var parser = Parser(lexer: Lexer(input: input))
      let program = parser.parseProgram()
      guard parser.errors.isEmpty else {
        printParserErrors(parser.errors)
        continue
      }
      let evaluated = eval(program, environment)
      if case .null = evaluated {
        printEnvironmentDebug(environment, enabled: options.debug)
      } else {
        print(evaluated)
        printEnvironmentDebug(environment, enabled: options.debug)
      }
    }
  }
}

private func printEnvironmentDebug(_ environment: Environment, enabled: Bool) {
  guard enabled else { return }
  debugPrint(environment)
}

func printParserErrors(_ errors: [String]) {
  print(monkeyFace)
  print("Woops! We ran into some monkey business here!")
  print(" parser errors:")
  for msg in errors {
    print("\t\(msg)")
  }
}
