#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../system_test_context'

class FunctionsTest < SystemTest
  FIXTURES = File.expand_path('../fixtures', __dir__)
  INTERPRETER = File.expand_path('../../lox/lox.rb', __dir__)

  TESTCASES = {
    'functions.lox' =>
      <<~OUTPUT.chomp
        true
        Hi, Dear Reader!
        3
        no return
        nil
        early
        1
        2
        21
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
