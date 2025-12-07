# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ruby on Lox is a Ruby implementation of the Lox programming language from the book "Crafting Interpreters" by Robert Nystrom. This is a tree-walk interpreter implementation following the book's jlox design, translated to idiomatic Ruby.

The project follows surgical, chapter-by-chapter commits that align with the book's structure. Each chapter's implementation is captured in discrete commits (see README.md for links).

## Running the Interpreter

**Run a Lox file:**
```bash
ruby lox/lox.rb path/to/file.lox
```

**Start REPL:**
```bash
ruby lox/lox.rb
```

## Testing

**Run all tests:**
```bash
rake test
```

**Run a specific test file:**
```bash
ruby tests/unit/scanner_test.rb
ruby tests/system/control_flow_test.rb
```

The test suite uses Minitest with custom test generation patterns:
- **Unit tests** (`tests/unit/`): Use `TESTCASES` hash with `generate_tests` to auto-create test methods
- **System tests** (`tests/system/`): Run complete `.lox` files from `tests/fixtures/` and verify output
- Both test types extend base classes (`UnitTest`, `SystemTest`) that provide `auto_test` and `generate_tests` helpers

## Architecture

### Interpreter Pipeline

The interpreter follows a classic multi-stage pipeline:

```
Source Code → Scanner → Tokens → Parser → AST → Interpreter → Output
```

1. **Scanner** (`lox/scanner.rb`): Lexical analysis - converts source text to tokens
2. **Parser** (`lox/parser.rb`): Syntax analysis - builds AST from tokens using recursive descent
3. **Interpreter** (`lox/interpreter.rb`): Walks the AST and executes the program

### AST Structure

AST nodes are defined in two modules using Structs with the Visitor pattern:

- **`Expr`** (`lox/expr.rb`): Expression nodes (Binary, Unary, Literal, Grouping, Variable, Assign, Logical)
- **`Stmt`** (`lox/stmt.rb`): Statement nodes (Expression, Print, Var, Block, If, While)

Each node has an `accept(visitor)` method that dispatches to the appropriate `visit_*` method on the visitor (currently only the Interpreter).

### Code Generation

The `tool/generate_ast.rb` script can generate AST node definitions from a declarative specification. While currently the AST files are hand-maintained, this tool demonstrates the pattern used in the book.

### Parser Design

The parser uses recursive descent with the following precedence hierarchy (lowest to highest):

```
expression → assignment → or → and → equality → comparison → term → factor → unary → primary
```

**Desugaring**: The `for` loop is desugared into `while` + blocks during parsing, requiring no interpreter support.

**Error Recovery**: The parser uses panic mode recovery with synchronization points at statement boundaries.

### Interpreter Execution

The interpreter implements the Visitor pattern:
- Expression visitors (`visit_binary`, `visit_logical`, etc.) return values
- Statement visitors (`visit_if_stmt`, `visit_while_stmt`, etc.) return `nil` and execute for side effects

**Environment**: Variable scoping uses a linked-list environment structure where each block creates a new Environment with a reference to its enclosing scope.

**Short-circuit evaluation**: Logical operators (`and`, `or`) are implemented in `visit_logical` to short-circuit - they return the decisive operand value, not just true/false.

## Key Patterns

### Test Fixtures

When adding new language features:
1. Create `.lox` test files in `tests/fixtures/`
2. Add test cases to appropriate test file using hash syntax: `'fixture.lox' => expected_output`
3. The test framework auto-generates individual test methods from the `TESTCASES` hash

### Adding AST Nodes

When implementing new language constructs:
1. Add Struct definition to `lox/expr.rb` or `lox/stmt.rb` with `accept` method
2. Add parsing logic to `lox/parser.rb`
3. Add `visit_*` method to `lox/interpreter.rb`

### Parser Precedence

To add new operators, insert them at the correct precedence level in the parser's method chain. Lower methods call higher-precedence methods.

## Idiomatic Ruby Patterns

- **Visitor pattern**: `node.accept(visitor)` → `visitor.visit_typename(node)`
- **Structs for data**: AST nodes are Structs with methods, not full classes
- **Module namespacing**: `Expr::Binary`, `Stmt::If` instead of separate classes
- **Symbols for enums**: Token types use Ruby symbols (`:left_paren`, `:while`, etc.)
- **Truthiness**: Ruby's truthiness (only `nil` and `false` are falsy) aligns with Lox semantics
