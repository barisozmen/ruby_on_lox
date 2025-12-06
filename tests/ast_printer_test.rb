require_relative '../lox/token'
require_relative '../lox/token_type'
require_relative '../lox/expr'
require_relative '../lox/ast_printer'

include TokenType

# Build the expression: -123 * (45.67)
expression = Expr::Binary.new(
  Expr::Unary.new(
    Token.new(MINUS, '-', nil, 1),
    Expr::Literal.new(123)
  ),
  Token.new(STAR, '*', nil, 1),
  Expr::Grouping.new(
    Expr::Literal.new(45.67)
  )
)

printer = AstPrinter.new
puts printer.print(expression)
