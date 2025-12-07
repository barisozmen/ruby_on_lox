#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../system_test_context'

class ControlFlowTest < SystemTest
  FIXTURES = File.expand_path('../fixtures', __dir__)
  INTERPRETER = File.expand_path('../../lox/lox.rb', __dir__)

  TESTCASES = {
    'control_flow_if.lox' =>
      <<~OUTPUT.chomp,
        x is greater than 3
        x is not less than 3
        or works
        and works
        x is exactly 5
        else binds to inner if
      OUTPUT

    'control_flow_loops.lox' =>
      <<~OUTPUT.chomp
        0
        1
        2
        0
        1
        2
        0
        1
        99
        center
        0
        1
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
