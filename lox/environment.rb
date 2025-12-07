require_relative 'runtime_error'

class Environment
  attr_reader :values, :enclosing

  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    return @values[name.lexeme] if @values.key?(name.lexeme)
    return @enclosing.get(name) if @enclosing

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def assign(name, value)
    if @values.key?(name.lexeme)
      @values[name.lexeme] = value
      return
    end

    if @enclosing
      @enclosing.assign(name, value)
      return
    end

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def get_at(distance, name)
    ancestor(distance).values[name]
  end

  def assign_at(distance, name, value)
    ancestor(distance).values[name] = value
  end

  def ancestor(distance)
    environment = self
    distance.times { environment = environment.enclosing }
    environment
  end
end
