require_relative 'runtime_error'
require_relative 'token_type'

class Interpreter
  def interpret(expression)
    value = evaluate(expression)
    puts stringify(value)
  rescue RuntimeError => e
    Lox.runtime_error(e)
  end

  def visit_literal(expr)
    expr.value
  end

  def visit_grouping(expr)
    evaluate(expr.expression)
  end

  def visit_unary(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::MINUS
      check_number_operand(expr.operator, right)
      -right
    when TokenType::BANG
      !truthy?(right)
    end
  end

  def visit_binary(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::MINUS
      check_number_operands(expr.operator, left, right)
      left - right
    when TokenType::SLASH
      check_number_operands(expr.operator, left, right)
      left / right
    when TokenType::STAR
      check_number_operands(expr.operator, left, right)
      left * right
    when TokenType::PLUS
      if left.is_a?(Float) && right.is_a?(Float)
        left + right
      elsif left.is_a?(String) && right.is_a?(String)
        left + right
      else
        raise RuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
      end
    when TokenType::GREATER
      check_number_operands(expr.operator, left, right)
      left > right
    when TokenType::GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left >= right
    when TokenType::LESS
      check_number_operands(expr.operator, left, right)
      left < right
    when TokenType::LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left <= right
    when TokenType::BANG_EQUAL
      !equal?(left, right)
    when TokenType::EQUAL_EQUAL
      equal?(left, right)
    end
  end

  private

  def evaluate(expr)
    expr.accept(self)
  end

  def truthy?(object)
    return false if object.nil?
    return object if object.is_a?(TrueClass) || object.is_a?(FalseClass)
    true
  end

  def equal?(a, b)
    return true if a.nil? && b.nil?
    return false if a.nil?
    a == b
  end

  def check_number_operand(operator, operand)
    return if operand.is_a?(Float)
    raise RuntimeError.new(operator, "Operand must be a number.")
  end

  def check_number_operands(operator, left, right)
    return if left.is_a?(Float) && right.is_a?(Float)
    raise RuntimeError.new(operator, "Operands must be numbers.")
  end

  def stringify(object)
    return "nil" if object.nil?

    if object.is_a?(Float)
      text = object.to_s
      text = text.chomp(".0") if text.end_with?(".0")
      return text
    end

    object.to_s
  end
end
