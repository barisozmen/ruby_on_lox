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
end
