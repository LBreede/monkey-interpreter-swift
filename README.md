# MonkeyInterpreter

A Swift implementation of the Monkey language from *Writing an Interpreter in Go*.

This project currently covers lexing, parsing, and the beginning of evaluation.
The default REPL evaluates Monkey source. Parser and lexer debug modes are also
available.

## Run the REPL

```sh
swift run MonkeyInterpreter
```

Example:

```text
Hello stranger! This is the Monkey programming language!
Feel free to type in commands
>> 5;
5
>> true;
true
>>
```

## Print the AST

Pass `--ast` to parse input and print the parsed AST back as a string. The
output is meant for structural parser debugging, not pretty-printing.

```sh
swift run MonkeyInterpreter --ast
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

For example, natural arithmetic precedence:

```text
>> let version = 1 + 50 / 2 - 8 * 3;
let version = ((1 + (50 / 2)) - (8 * 3));
>>
```

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
statements or evaluated objects:

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

The same closure example in token mode shows how parameters and arguments are
lexed as parenthesized, comma-separated lists:

```text
>> let newAdder = fn(a, b) { fn(c) { a + b + c }; };
letKeyword
ident("newAdder")
assign
fnKeyword
lparen
ident("a")
comma
ident("b")
rparen
lbrace
fnKeyword
lparen
ident("c")
rparen
lbrace
ident("a")
plus
ident("b")
plus
ident("c")
rbrace
semicolon
rbrace
semicolon
>> let adder = newAdder(1, 2);
letKeyword
ident("adder")
assign
ident("newAdder")
lparen
int("1")
comma
int("2")
rparen
semicolon
>> adder(8);
ident("adder")
lparen
int("8")
rparen
semicolon
>>
```

## Test

```sh
swift test
```
