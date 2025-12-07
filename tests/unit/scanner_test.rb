require_relative '../unit_test_context'
require_relative '../../lox/scanner'

class ScannerTest < Minitest::Test
  auto_test do |source, expected|
    tokens = Scanner.new(source).scan_tokens

    expected.each_with_index do |exp, i|
      case exp
      when Symbol
        assert_equal exp, tokens[i].type
      when Hash
        assert_equal exp[:type], tokens[i].type if exp[:type]
        assert_equal exp[:lexeme], tokens[i].lexeme if exp[:lexeme]
        assert_equal exp[:literal], tokens[i].literal if exp[:literal]
        assert_equal exp[:line], tokens[i].line if exp[:line]
      end
    end
  end

  TESTCASES = {
    # Single-character tokens
    '(){},.;+-*' =>
      [:left_paren, :right_paren, :left_brace, :right_brace, :comma, :dot, :semicolon, :plus, :minus, :star, :eof],

    # One or two character operators
    '! != = == < <= > >=' =>
      [:bang, :bang_equal, :equal, :equal_equal, :less, :less_equal, :greater, :greater_equal, :eof],

    # Comments
    "/ // comment\n/" =>
      [:slash, :slash, :eof],

    # Whitespace handling
    "  \r\t\n  +  " =>
      [{type: :plus, line: 2}, :eof],

    # String literals
    '"hello"' =>
      [{type: :string, literal: 'hello'}, :eof],

    # Multiline strings
    "\"hello\nworld\"" =>
      [{type: :string, literal: "hello\nworld", line: 2}, :eof],

    # Number literals
    '123 123.456' =>
      [{type: :number, literal: 123.0}, {type: :number, literal: 123.456}, :eof],

    # Identifiers
    'foo _bar baz123' =>
      [{type: :identifier, lexeme: 'foo'}, {type: :identifier, lexeme: '_bar'}, {type: :identifier, lexeme: 'baz123'}, :eof],

    # Keywords
    'and class else false for fun if nil or print return super this true var while' =>
      [:and, :class, :else, :false, :for, :fun, :if, :nil, :or, :print, :return, :super, :this, :true, :var, :while, :eof],

    # Maximal munch
    'orchid' =>
      [{type: :identifier, lexeme: 'orchid'}, :eof],

    # Complete statement
    'var language = "lox";' =>
      [{type: :var}, {type: :identifier, lexeme: 'language'}, :equal, {type: :string, literal: 'lox'}, :semicolon, :eof]
  }

  generate_tests
end
