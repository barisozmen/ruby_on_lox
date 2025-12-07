require_relative 'scanner'
require_relative 'parser'
require_relative 'interpreter'
require_relative 'resolver'

class Lox
  @had_error = false
  @had_runtime_error = false
  @interpreter = Interpreter.new

  def self.main(args)
    if args.length > 1
      puts 'Usage: ruby lox.rb [script]'
      exit(64)
    elsif args.length == 1
      run_file(args[0])
    else
      run_prompt
    end
  end

  def self.run_file(path)
    run(File.read(path))
    exit(65) if @had_error
    exit(70) if @had_runtime_error
  end

  def self.run_prompt
    loop do
      print '> '
      line = gets
      break unless line

      run(line)
      @had_error = false
    end
  end

  def self.run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens
    parser = Parser.new(tokens)
    statements = parser.parse

    return if @had_error || statements.nil?

    resolver = Resolver.new(@interpreter)
    resolver.resolve(statements)

    return if @had_error

    @interpreter.interpret(statements)
  end

  def self.error(token_or_line, message)
    if token_or_line.is_a?(Integer)
      report(token_or_line, '', message)
    else
      token = token_or_line
      where = token.type == TokenType::EOF ? ' at end' : " at '#{token.lexeme}'"
      report(token.line, where, message)
    end
  end

  def self.report(line, where, message)
    warn "[line #{line}] Error#{where}: #{message}"
    @had_error = true
  end

  def self.runtime_error(error)
    warn "#{error.message}\n[line #{error.token.line}]"
    @had_runtime_error = true
  end
end

Lox.main(ARGV) if __FILE__ == $0
