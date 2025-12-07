#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../system_test_context'

class ClassesTest < SystemTest
  FIXTURES = File.expand_path('../fixtures', __dir__)
  INTERPRETER = File.expand_path('../../lox/lox.rb', __dir__)

  TESTCASES = {
    'classes.lox' =>
      <<~OUTPUT.chomp
        Bagel instance
        Alice
        30
        8
        78.5
        10
        11
        something
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
