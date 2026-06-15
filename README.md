# MonkeyInterpreter

A Swift implementation of the Monkey language from *Writing an Interpreter in Go*.

This project currently covers lexing and parsing. The REPL reads Monkey source and
prints the parsed AST back as a string. The output is meant for structural parser
debugging, not pretty-printing.

## Run the REPL

```sh
swift run MonkeyInterpreter
```

Example Monkey source:

```monkey
let fibonacci = fn(x) {
  if (x == 0) {
    0
  } else {
    if (x == 1) {
      return 1;
    } else {
      fibonacci(x - 1) + fibonacci(x - 2);
    }
  }
};
```

The REPL currently reads one line at a time, so enter the program as one line:

```text
Hello stranger! This is the Monkey programming language!
Feel free to type in commands
>> let fibonacci = fn(x) { if (x == 0) { 0 } else { if (x == 1) { return 1; } else { fibonacci(x - 1) + fibonacci(x - 2); } } };
let fibonacci = fn(x) { if (x == 0) { 0 } else { if (x == 1) { return 1; } else { (fibonacci((x - 1)) + fibonacci((x - 2))) } } };
>>
```

The extra parentheses show how the parser grouped expressions according to
operator precedence.

Another example, adapted from the Monkey website, shows function literals and
calls. Comments and evaluation are not implemented yet, so this example omits
the original comments and prints parsed AST strings instead of a result value.

```monkey
let newAdder = fn(a, b) {
  fn(c) { a + b + c };
};

let adder = newAdder(1, 2);
adder(8);
```

```text
>> let newAdder = fn(a, b) { fn(c) { a + b + c }; };
let newAdder = fn(a, b) { fn(c) { ((a + b) + c) } };
>> let adder = newAdder(1, 2);
let adder = newAdder(1, 2);
>> adder(8);
adder(8)
>>
```

## Print Tokens

Pass `--tokens` to run the lexer directly and print tokens instead of parsed
statements:

```sh
swift run MonkeyInterpreter --tokens
```

Example:

```text
Hello stranger! This is the Monkey programming language!
Feel free to type in commands
>> let fibonacci = fn(x) { if (x == 0) { 0 } };
letKeyword
ident("fibonacci")
assign
fnKeyword
lparen
ident("x")
rparen
lbrace
ifKeyword
lparen
ident("x")
eq
int("0")
rparen
lbrace
int("0")
rbrace
rbrace
semicolon
>>
```

## Test

```sh
swift test
```
