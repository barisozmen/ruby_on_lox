require_relative 'runtime_error'
require_relative 'token_type'
require_relative 'environment'
require_relative 'lox_function'
require_relative 'lox_class'
require_relative 'return_exception'

class Interpreter
  def initialize
    @globals = Environment.new
    @environment = @globals
    @locals = {}.compare_by_identity

    # Native function: clock
    @globals.define("clock", Class.new do
      include LoxCallable

      def arity
        0
      end

      def call(interpreter, arguments)
        Time.now.to_f
      end

      def to_s
        "<native fn>"
      end
    end.new)
  end

  def interpret(statements)
    statements.each { |statement| execute(statement) }
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
      if right.zero?
        raise RuntimeError.new(expr.operator, "Cannot divide by zero. Attempted to divide #{left} by #{right}")
      end
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

  def visit_variable(expr)
    look_up_variable(expr.name, expr)
  end

  def visit_assign(expr)
    value = evaluate(expr.value)

    distance = @locals[expr]
    if distance
      @environment.assign_at(distance, expr.name.lexeme, value)
    else
      @globals.assign(expr.name, value)
    end

    value
  end

  def visit_logical(expr)
    left = evaluate(expr.left)

    if expr.operator.type == TokenType::OR
      return left if truthy?(left)
    else
      return left unless truthy?(left)
    end

    evaluate(expr.right)
  end

  def visit_call(expr)
    callee = evaluate(expr.callee)
    arguments = expr.arguments.map { |arg| evaluate(arg) }

    unless callee.is_a?(LoxCallable)
      raise RuntimeError.new(expr.paren, "Can only call functions and classes.")
    end

    if arguments.length != callee.arity
      raise RuntimeError.new(expr.paren, "Expected #{callee.arity} arguments but got #{arguments.length}.")
    end

    callee.call(self, arguments)
  end

  def visit_get(expr)
    object = evaluate(expr.object)
    return object.get(expr.name) if object.is_a?(LoxInstance)

    raise RuntimeError.new(expr.name, "Only instances have properties.")
  end

  def visit_set(expr)
    object = evaluate(expr.object)

    unless object.is_a?(LoxInstance)
      raise RuntimeError.new(expr.name, "Only instances have fields.")
    end

    value = evaluate(expr.value)
    object.set(expr.name, value)
    value
  end

  def visit_this(expr)
    look_up_variable(expr.keyword, expr)
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
    nil
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
    nil
  end

  def visit_var_stmt(stmt)
    value = stmt.initializer ? evaluate(stmt.initializer) : nil
    @environment.define(stmt.name.lexeme, value)
    nil
  end

  def visit_block_stmt(stmt)
    execute_block(stmt.statements, Environment.new(@environment))
    nil
  end

  def visit_if_stmt(stmt)
    if truthy?(evaluate(stmt.condition))
      execute(stmt.then_branch)
    elsif stmt.else_branch
      execute(stmt.else_branch)
    end
    nil
  end

  def visit_while_stmt(stmt)
    execute(stmt.body) while truthy?(evaluate(stmt.condition))
    nil
  end

  def visit_function_stmt(stmt)
    function = LoxFunction.new(stmt, @environment)
    @environment.define(stmt.name.lexeme, function)
    nil
  end

  def visit_class_stmt(stmt)
    @environment.define(stmt.name.lexeme, nil)

    methods = {}
    stmt.methods.each do |method|
      function = LoxFunction.new(method, @environment, method.name.lexeme == "init")
      methods[method.name.lexeme] = function
    end

    klass = LoxClass.new(stmt.name.lexeme, methods)
    @environment.assign(stmt.name, klass)
    nil
  end

  def visit_return_stmt(stmt)
    value = stmt.value ? evaluate(stmt.value) : nil
    raise ReturnException.new(value)
  end

  def execute_block(statements, environment)
    previous = @environment
    begin
      @environment = environment
      statements.each { |statement| execute(statement) }
    ensure
      @environment = previous
    end
  end

  def resolve(expr, depth)
    @locals[expr] = depth
  end

  private

  def look_up_variable(name, expr)
    distance = @locals[expr]
    if distance
      @environment.get_at(distance, name.lexeme)
    else
      @globals.get(name)
    end
  end

  def execute(stmt)
    stmt.accept(self)
  end

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
