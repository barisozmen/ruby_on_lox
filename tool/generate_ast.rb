#!/usr/bin/env ruby

class GenerateAst
  def self.run(args)
    if args.length != 1
      puts 'Usage: generate_ast <output directory>'
      exit 64
    end

    output_dir = args[0]
    define_ast(output_dir, 'Expr', [
      'Binary   : Expr left, Token operator, Expr right',
      'Grouping : Expr expression',
      'Literal  : Object value',
      'Unary    : Token operator, Expr right'
    ])
  end

  def self.define_ast(output_dir, base_name, types)
    path = "#{output_dir}/#{base_name.downcase}.rb"

    File.open(path, 'w') do |file|
      file.puts "module #{base_name}"

      types.each do |type|
        class_name, fields = type.split(':').map(&:strip)
        field_list = fields.split(',').map { |f| f.strip.split(' ').last.to_sym }

        file.puts "  #{class_name} = Struct.new(#{field_list.map(&:inspect).join(', ')}) do"
        file.puts "    def accept(visitor)"
        file.puts "      visitor.visit_#{class_name.downcase}(self)"
        file.puts "    end"
        file.puts "  end"
        file.puts
      end

      file.puts "end"
    end

    puts "Generated #{path}"
  end
end

GenerateAst.run(ARGV) if __FILE__ == $PROGRAM_NAME
