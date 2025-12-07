require_relative 'token_type'
require_relative 'expr'
require_relative 'stmt'

class Parser
  include TokenType

  class ParseError < StandardError; end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []
    statements << declaration until at_end?
    statements
  rescue ParseError
    nil
  end

  private

  def declaration
    return var_declaration if match(VAR)
    statement
  rescue ParseError
    synchronize
    nil
  end

  def var_declaration
    name = consume(IDENTIFIER, "Expect variable name.")
    initializer = match(EQUAL) ? expression : nil
    consume(SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  def statement
    return if_statement if match(IF)
    return while_statement if match(WHILE)
    return for_statement if match(FOR)
    return print_statement if match(PRINT)
    return block if match(LEFT_BRACE)
    expression_statement
  end

  def print_statement
    value = expression
    consume(SEMICOLON, "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  def expression_statement
    expr = expression
    consume(SEMICOLON, "Expect ';' after expression.")
    Stmt::Expression.new(expr)
  end

  def block
    statements = []
    statements << declaration until check(RIGHT_BRACE) || at_end?
    consume(RIGHT_BRACE, "Expect '}' after block.")
    Stmt::Block.new(statements)
  end

  def if_statement
    consume(LEFT_PAREN, "Expect '(' after 'if'.")
    condition = expression
    consume(RIGHT_PAREN, "Expect ')' after if condition.")

    then_branch = statement
    else_branch = match(ELSE) ? statement : nil

    Stmt::If.new(condition, then_branch, else_branch)
  end

  def while_statement
    consume(LEFT_PAREN, "Expect '(' after 'while'.")
    condition = expression
    consume(RIGHT_PAREN, "Expect ')' after condition.")
    body = statement

    Stmt::While.new(condition, body)
  end

  def for_statement
    consume(LEFT_PAREN, "Expect '(' after 'for'.")

    initializer = if match(SEMICOLON)
                    nil
                  elsif match(VAR)
                    var_declaration
                  else
                    expression_statement
                  end

    condition = check(SEMICOLON) ? nil : expression
    consume(SEMICOLON, "Expect ';' after loop condition.")

    increment = check(RIGHT_PAREN) ? nil : expression
    consume(RIGHT_PAREN, "Expect ')' after for clauses.")

    body = statement

    # Desugar to while loop
    body = Stmt::Block.new([body, Stmt::Expression.new(increment)]) if increment
    body = Stmt::While.new(condition || Expr::Literal.new(true), body)
    body = Stmt::Block.new([initializer, body]) if initializer

    body
  end

  def expression
    assignment
  end

  def assignment
    expr = or_expr

    if match(EQUAL)
      equals = previous
      value = assignment

      if expr.is_a?(Expr::Variable)
        return Expr::Assign.new(expr.name, value)
      end

      error(equals, "Invalid assignment target.")
    end

    expr
  end

  def or_expr
    expr = and_expr

    while match(OR)
      operator = previous
      right = and_expr
      expr = Expr::Logical.new(expr, operator, right)
    end

    expr
  end

  def and_expr
    expr = equality

    while match(AND)
      operator = previous
      right = equality
      expr = Expr::Logical.new(expr, operator, right)
    end

    expr
  end

  def equality
    expr = comparison

    while match(BANG_EQUAL, EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = term

    while match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def term
    expr = factor

    while match(MINUS, PLUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def factor
    expr = unary

    while match(SLASH, STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(BANG, MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end

    primary
  end

  def primary
    return Expr::Literal.new(false) if match(FALSE)
    return Expr::Literal.new(true) if match(TRUE)
    return Expr::Literal.new(nil) if match(NIL)
    return Expr::Literal.new(previous.literal) if match(NUMBER, STRING)
    return Expr::Variable.new(previous) if match(IDENTIFIER)

    if match(LEFT_PAREN)
      expr = expression
      consume(RIGHT_PAREN, "Expect ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error(peek, "Expect expression.")
  end

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end
    false
  end

  def check(type)
    return false if at_end?
    peek.type == type
  end

  def advance
    @current += 1 unless at_end?
    previous
  end

  def at_end?
    peek.type == EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def consume(type, message)
    return advance if check(type)
    raise error(peek, message)
  end

  def error(token, message)
    Lox.error(token, message)
    ParseError.new
  end

  def synchronize
    advance

    until at_end?
      return if previous.type == SEMICOLON

      case peek.type
      when CLASS, FUN, VAR, FOR, IF, WHILE, PRINT, RETURN
        return
      end

      advance
    end
  end
end
