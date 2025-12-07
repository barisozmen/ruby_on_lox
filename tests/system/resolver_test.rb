#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../system_test_context'

class ResolverTest < SystemTest
  FIXTURES = File.expand_path('../fixtures', __dir__)
  INTERPRETER = File.expand_path('../../lox/lox.rb', __dir__)

  # Test cases that should execute successfully
  TESTCASES = {
    'resolver_scoping.lox' =>
      <<~OUTPUT.chomp,
        global
        global
        inner x
        outer x
        3
        outer
        inner
        outer
        global
        original
      OUTPUT

    'resolver_edge_cases.lox' =>
      <<~OUTPUT.chomp
        1
        first
        second
        third
        second
        first
        0
        1
        1
        outside
        after
        global
        local
      OUTPUT
  }.freeze

  auto_test do |fixture, expected|
    stdout = run_lox(fixture)
    assert_equal expected, stdout.strip
  end

  # Test cases that should produce resolver errors
  def test_duplicate_local_variable_error
    code = <<~LOX
      {
        var a = "first";
        var a = "second";
      }
    LOX

    stderr = run_lox_with_error(code)
    assert_match(/Already a variable with this name in this scope/, stderr)
  end

  def test_use_before_initialization_error
    code = <<~LOX
      {
        var a = a;
      }
    LOX

    stderr = run_lox_with_error(code)
    assert_match(/Can't read local variable in its own initializer/, stderr)
  end

  def test_invalid_top_level_return_error
    code = <<~LOX
      return "oops";
    LOX

    stderr = run_lox_with_error(code)
    assert_match(/Can't return from top-level code/, stderr)
  end

  def test_closure_captures_at_declaration_time
    code = <<~LOX
      var a = "global";
      var closure;
      {
        fun captureA() {
          print a;
        }
        closure = captureA;
        var a = "block";
      }
      closure();
    LOX

    stdout, stderr, status = run_lox_direct(code)
    assert status.success?, "Execution failed:\n#{stderr}"
    assert_equal "global", stdout.strip
  end

  def test_nested_scope_resolution
    code = <<~LOX
      var a = "a0";
      {
        var a = "a1";
        {
          var a = "a2";
          print a;
        }
        print a;
      }
      print a;
    LOX

    stdout, stderr, status = run_lox_direct(code)
    assert status.success?, "Execution failed:\n#{stderr}"
    assert_equal "a2\na1\na0", stdout.strip
  end

  def test_for_loop_variable_scoping
    code = <<~LOX
      var i = "before";
      for (var i = 0; i < 3; i = i + 1) {
        print i;
      }
      print i;
    LOX

    stdout, stderr, status = run_lox_direct(code)
    assert status.success?, "Execution failed:\n#{stderr}"
    assert_equal "0\n1\n2\nbefore", stdout.strip
  end

  private

  def run_lox(fixture)
    source = File.join(self.class::FIXTURES, fixture)
    stdout, stderr, status = Open3.capture3("ruby #{self.class::INTERPRETER} #{source}")
    assert status.success?, "Execution failed:\n#{stderr}"
    stdout
  end

  def run_lox_with_error(code)
    require 'tempfile'
    Tempfile.create(['test', '.lox']) do |f|
      f.write(code)
      f.flush
      stdout, stderr, status = Open3.capture3("ruby #{self.class::INTERPRETER} #{f.path}")
      refute status.success?, "Expected execution to fail but it succeeded"
      return stderr
    end
  end

  def run_lox_direct(code)
    require 'tempfile'
    Tempfile.create(['test', '.lox']) do |f|
      f.write(code)
      f.flush
      return Open3.capture3("ruby #{self.class::INTERPRETER} #{f.path}")
    end
  end

  generate_tests
end
