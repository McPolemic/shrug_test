module Shrug
  TestResponse = Struct.new(:pass?, :human_response)

  class Test
    def assert(conditional)
      TestResponse.new(conditional)
    end

    def refute(conditional)
      TestResponse.new(!conditional)
    end

    def assert_equals(left, right)
      human_response = "Expected #{left} to equal #{right}"
      TestResponse.new(left == right, human_response)
    end

    def self.test(name, &block)
      method_name = "test #{name}".gsub(/[^a-z]/, '_').to_sym
      define_method(method_name, block)
    end

    def run
      test_methods = methods.find_all{ |m| m[/^test_/]}
      failed = {}

      test_methods.each do |test_method|
        result = method(test_method).call

        if result.pass?
          print '.'
        else
          print 'X'
          failed[test_method] = result
        end
      end

      print "\n"
      return if failed.empty?

      puts "\nFailed tests:"
      failed.each do |name, response|
        puts "* #{name}"
        puts " " * 4 + response.human_response
      end
    end
  end
end

class Generic
end

class GenericTest < Shrug::Test
  test 'i can assert things' do
    assert 1==1
  end

  test 'i can refute things' do
    refute false
  end

  test 'i can assert things are equal' do
    assert_equals 1, 1
  end

  test 'i can fail an assertion and show the arguments' do
    assert_equals(2+2, 7)
  end
end

GenericTest.new.run
