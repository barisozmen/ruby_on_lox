require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use!
require "debug"

class Minitest::Test
  def self.auto_test(&block)
    @auto_test_block = block
  end

  def self.generate_tests
    return unless const_defined?(:TESTCASES, false)

    const_get(:TESTCASES).each_with_index do |(input, expected), i|
      define_method("test_testcase_#{i}") do
        instance_exec(input, expected, &self.class.instance_variable_get(:@auto_test_block))
      end
    end
  end
end