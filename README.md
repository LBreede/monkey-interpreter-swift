# MonkeyInterpreter

A Swift implementation of the Monkey language from *Writing an Interpreter in Go*.

This project currently covers lexing and parsing. The REPL reads Monkey source and
prints the parsed AST back as a string. The output is meant for structural parser
debugging, not pretty-printing.

## Run the REPL

```sh
swift run MonkeyInterpreter
```

Example:

```text
Hello stranger! This is the Monkey programming language!
Feel free to type in commands
>> let sumOfDoubles = fn(x, y) { let x = 2*x; let y = 2*y; let z = x + y; return z; };
let sumOfDoubles = fn(x, y) { let x = (2 * x);let y = (2 * y);let z = (x + y);return z; };
>> add(1, 2 * 3, 4 + 5);
add(1, (2 * 3), (4 + 5))
>>
```

The extra parentheses show how the parser grouped expressions according to
operator precedence.

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
>> let add = fn(x, y) { x + y; };
let
IDENT(add)
=
fn
(
IDENT(x)
,
IDENT(y)
)
{
IDENT(x)
+
IDENT(y)
;
}
;
>>
```

## Test

```sh
swift test
```
