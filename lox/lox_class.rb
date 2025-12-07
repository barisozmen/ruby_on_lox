require_relative 'lox_callable'
require_relative 'lox_instance'

class LoxClass
  include LoxCallable

  attr_reader :name

  def initialize(name, methods)
    @name = name
    @methods = methods
  end

  def call(interpreter, arguments)
    instance = LoxInstance.new(self)
    initializer = find_method("init")
    initializer&.bind(instance)&.call(interpreter, arguments)
    instance
  end

  def arity
    initializer = find_method("init")
    initializer ? initializer.arity : 0
  end

  def find_method(name)
    @methods[name]
  end

  def to_s
    name
  end
end
