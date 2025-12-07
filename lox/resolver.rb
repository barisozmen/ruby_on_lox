class Resolver
  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
    @current_function = :none
  end

  # Statements
  def visit_block_stmt(stmt)
    begin_scope
    resolve(stmt.statements)
    end_scope
    nil
  end

  def visit_var_stmt(stmt)
    declare(stmt.name)
    resolve(stmt.initializer) if stmt.initializer
    define(stmt.name)
    nil
  end

  def visit_function_stmt(stmt)
    declare(stmt.name)
    define(stmt.name)
    resolve_function(stmt, :function)
    nil
  end

  def visit_expression_stmt(stmt)
    resolve(stmt.expression)
    nil
  end

  def visit_if_stmt(stmt)
    resolve(stmt.condition)
    resolve(stmt.then_branch)
    resolve(stmt.else_branch) if stmt.else_branch
    nil
  end

  def visit_print_stmt(stmt)
    resolve(stmt.expression)
    nil
  end

  def visit_return_stmt(stmt)
    if @current_function == :none
      Lox.error(stmt.keyword, "Can't return from top-level code.")
    end
    resolve(stmt.value) if stmt.value
    nil
  end

  def visit_while_stmt(stmt)
    resolve(stmt.condition)
    resolve(stmt.body)
    nil
  end

  # Expressions
  def visit_variable(expr)
    if !@scopes.empty? && @scopes.last[expr.name.lexeme] == false
      Lox.error(expr.name, "Can't read local variable in its own initializer.")
    end
    resolve_local(expr, expr.name)
    nil
  end

  def visit_assign(expr)
    resolve(expr.value)
    resolve_local(expr, expr.name)
    nil
  end

  def visit_binary(expr)
    resolve(expr.left)
    resolve(expr.right)
    nil
  end

  def visit_call(expr)
    resolve(expr.callee)
    expr.arguments.each { |arg| resolve(arg) }
    nil
  end

  def visit_grouping(expr)
    resolve(expr.expression)
    nil
  end

  def visit_literal(expr)
    nil
  end

  def visit_logical(expr)
    resolve(expr.left)
    resolve(expr.right)
    nil
  end

  def visit_unary(expr)
    resolve(expr.right)
    nil
  end

  # Public interface
  def resolve(statements_or_statement)
    if statements_or_statement.is_a?(Array)
      statements_or_statement.each { |stmt| resolve(stmt) }
    else
      statements_or_statement&.accept(self)
    end
  end

  private

  def begin_scope
    @scopes.push({})
  end

  def end_scope
    @scopes.pop
  end

  def declare(name)
    return if @scopes.empty?
    scope = @scopes.last
    if scope.key?(name.lexeme)
      Lox.error(name, "Already a variable with this name in this scope.")
    end
    scope[name.lexeme] = false
  end

  def define(name)
    return if @scopes.empty?
    @scopes.last[name.lexeme] = true
  end

  def resolve_local(expr, name)
    (@scopes.length - 1).downto(0) do |i|
      if @scopes[i].key?(name.lexeme)
        @interpreter.resolve(expr, @scopes.length - 1 - i)
        return
      end
    end
  end

  def resolve_function(function, type)
    enclosing_function = @current_function
    @current_function = type

    begin_scope
    function.params.each do |param|
      declare(param)
      define(param)
    end
    resolve(function.body)
    end_scope

    @current_function = enclosing_function
  end
end
