require_relative 'lox_callable'
require_relative 'lox_instance'

class LoxClass
  include LoxCallable

  attr_reader :name

  def initialize(name, superclass, methods)
    @name = name
    @superclass = superclass
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
    return @methods[name] if @methods.key?(name)
    return @superclass.find_method(name) if @superclass
    nil
  end

  def to_s
    name
  end
end
