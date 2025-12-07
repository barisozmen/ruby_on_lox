#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../system_test_context'

class InheritanceTest < SystemTest
  FIXTURES = File.expand_path('../fixtures', __dir__)
  INTERPRETER = File.expand_path('../../lox/lox.rb', __dir__)

  TESTCASES = {
    'inheritance_basic.lox' =>
      <<~OUTPUT.chomp,
        Some sound
        Meow
        Some sound
        Chirp
        Some sound
        Chirp
        Hello, I'm Alice
        I code in Ruby
        4
      OUTPUT

    'inheritance_edge_cases.lox' =>
      <<~OUTPUT.chomp
        A
        B
        C
        D
        Base.foo
        Base.bar
        Parent init
        Child init
        I am a rectangle
        50
        3
      OUTPUT
  }.freeze

  auto_test do |fixture, expected|
    stdout = run_lox(fixture)
    assert_equal expected, stdout.strip
  end

  private

  def run_lox(fixture)
    source = File.join(self.class::FIXTURES, fixture)
    stdout, stderr, status = Open3.capture3("ruby #{self.class::INTERPRETER} #{source}")
    assert status.success?, "Execution failed:\n#{stderr}"
    stdout
  end

  generate_tests
end
