module Expr
  Binary = Struct.new(:left, :operator, :right) do
    def accept(visitor)
      visitor.visit_binary(self)
    end
  end

  Grouping = Struct.new(:expression) do
    def accept(visitor)
      visitor.visit_grouping(self)
    end
  end

  Literal = Struct.new(:value) do
    def accept(visitor)
      visitor.visit_literal(self)
    end
  end

  Unary = Struct.new(:operator, :right) do
    def accept(visitor)
      visitor.visit_unary(self)
    end
  end

  Variable = Struct.new(:name) do
    def accept(visitor)
      visitor.visit_variable(self)
    end
  end

  Assign = Struct.new(:name, :value) do
    def accept(visitor)
      visitor.visit_assign(self)
    end
  end

  Logical = Struct.new(:left, :operator, :right) do
    def accept(visitor)
      visitor.visit_logical(self)
    end
  end
end
