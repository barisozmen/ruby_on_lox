require_relative 'lox_callable'
require_relative 'environment'
require_relative 'return_exception'

class LoxFunction
  include LoxCallable

  def initialize(declaration, closure, is_initializer = false)
    @declaration = declaration
    @closure = closure
    @is_initializer = is_initializer
  end

  def arity
    @declaration.params.length
  end

  def call(interpreter, arguments)
    environment = Environment.new(@closure)

    @declaration.params.each_with_index do |param, index|
      environment.define(param.lexeme, arguments[index])
    end

    begin
      interpreter.execute_block(@declaration.body, environment)
    rescue ReturnException => e
      return @closure.get_at(0, "this") if @is_initializer
      return e.value
    end

    return @closure.get_at(0, "this") if @is_initializer
    nil
  end

  def bind(instance)
    environment = Environment.new(@closure)
    environment.define("this", instance)
    LoxFunction.new(@declaration, environment, @is_initializer)
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
