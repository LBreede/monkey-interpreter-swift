#if canImport(Glibc)
  import Glibc
#elseif canImport(Darwin)
  import Darwin
#endif

let user = getenv("USER").map { String(cString: $0) } ?? "stranger"
print("Hello \(user)! This is the Monkey programming language!")
print("Feel free to type in commands")
let mode: ReplMode =
  if CommandLine.arguments.contains("--tokens") {
    .tokens
  } else if CommandLine.arguments.contains("--ast") {
    .statements
  } else {
    .evaluator
  }
startRepl(mode: mode)
