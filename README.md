# Ruby on Lox

Tree-walk interpreter for the Lox programming language, written in idiomatic Ruby. A chapter-by-chapter implementation of [Crafting Interpreters](https://craftinginterpreters.com).

<img width="216" height="204" alt="lox" src="https://github.com/user-attachments/assets/3c01e048-7409-43c0-a37f-e4d9c78f8c5b" />

## Getting Started

```bash
# Run a program
bin/lox examples/hello.lox

# Start REPL
bin/lox
```

## Example Programs

**Fibonacci**
```lox
fun fibonacci(n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}

print fib(10);
```

**Counter Class**
```lox
class Counter {
  init(start) {
    this.count = start;
  }

  increment() {
    this.count = this.count + 1;
  }

  value() {
    return this.count;
  }
}

var counter = Counter(0);
counter.increment();
counter.increment();
print counter.value();
```

## Reference
- [intro](https://craftinginterpreters.com/the-lox-language.html)
- [grammar](https://craftinginterpreters.com/appendix-i.html)

## Implementation

- **Scanner** (`lox/scanner.rb`) - Lexical analysis
- **Parser** (`lox/parser.rb`) - Recursive descent parser
- **Resolver** (`lox/resolver.rb`) - Variable resolution & binding
- **Interpreter** (`lox/interpreter.rb`) - Tree-walk execution
- **AST** (`lox/expr.rb`, `lox/stmt.rb`) - Expression & statement nodes

## Surgical Commits

Each chapter implemented in a discrete commit:

- Ch 4-5: [Scanning](https://craftinginterpreters.com/scanning.html) & [Representing Code](https://craftinginterpreters.com/representing-code.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/6848096311773528bf13ea2d019c5ff7faebb657)]
- Ch 6: [Parsing Expressions](https://craftinginterpreters.com/parsing-expressions.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/4a4f3f3b79eae01c1ea4dfd09406de35c9602c8b)]
- Ch 7: [Evaluating Expressions](https://craftinginterpreters.com/evaluating-expressions.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/cf505f69166a6c5a62fae3a852421008d6526208)]
- Ch 8: [Statements and State](https://craftinginterpreters.com/statements-and-state.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/a411e1e68d214f8220e9d062d78f812c46b0cea7)]
- Ch 9: [Control Flow](https://craftinginterpreters.com/control-flow.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/1c6f8819a87f57c23a522b53832ad37b7433ea1a)]
- Ch 10: [Functions](https://craftinginterpreters.com/functions.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/eb6b899ce5323ecb7c1de4028acb6ca949566d32)]
- Ch 11: [Resolving and Binding](https://craftinginterpreters.com/resolving-and-binding.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/ea038a4a7d5037d2a77bba66109404e96e319edc)]
- Ch 12: [Classes](https://craftinginterpreters.com/classes.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/8914746ead3d2bd89f9d5e3fcd1afcba049fcae9)]
- Ch 13: [Inheritance](https://craftinginterpreters.com/inheritance.html) [[commit](https://github.com/barisozmen/ruby_on_lox/commit/54b2d8c19a4b8493727e375fc7827873482c1c70)]

## Testing
```bash
rake test
```