require_relative 'scanner'

class Lox
  @had_error = false

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

    tokens.each { |token| puts token }
  end

  def self.error(line, message)
    report(line, '', message)
  end

  def self.report(line, where, message)
    warn "[line #{line}] Error#{where}: #{message}"
    @had_error = true
  end
end

Lox.main(ARGV) if __FILE__ == $0
