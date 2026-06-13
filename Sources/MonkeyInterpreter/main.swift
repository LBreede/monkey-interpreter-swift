#if canImport(Glibc)
  import Glibc
#elseif canImport(Darwin)
  import Darwin
#endif

let user = getenv("USER").map { String(cString: $0) } ?? "stranger"
print("Hello \(user)! This is the Monkey programming language!")
print("Feel free to type in commands")
let mode: ReplMode = CommandLine.arguments.contains("--tokens") ? .tokens : .statements
startRepl(mode: mode)
