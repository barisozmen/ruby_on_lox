require_relative 'lox_callable'
require_relative 'environment'
require_relative 'return_exception'

class LoxFunction
  include LoxCallable

  def initialize(declaration, closure)
    @declaration = declaration
    @closure = closure
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
      return e.value
    end

    nil
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
