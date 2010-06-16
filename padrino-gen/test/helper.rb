require File.expand_path('../../../load_paths', __FILE__)
require 'riot'
require 'mocha'
require 'rack/test'
require 'webrat'
require 'thor/group'
require 'padrino-gen'
require 'padrino-core/support_lite' unless defined?(SupportLite)

Padrino::Generators.load_components!

Riot.reporter = Riot::DotMatrixReporter

class Riot::Situation
  include Rack::Test::Methods

  def stop_time_for_test
    time = Time.now
    Time.stubs(:now).returns(time)
    return time
  end

  # generate(:controller, 'DemoItems', '-r=/tmp/sample_project')
  def generate(name, *params)
    "Padrino::Generators::#{name.to_s.camelize}".constantize.start(params)
  end

end

class Riot::Context
  include Webrat::Methods
  include Webrat::Matchers

  Webrat.configure { |config| config.mode = :rack }

  #clean up the testing directory
  def clean_up!(path="/tmp/sample_project")
    setup { system("rm -rf #{path}") }
    teardown { system("rm -rf #{path}") }
  end

  # assert_has_tag(:h1, :content => "yellow") { "<h1>yellow</h1>" }
  # In this case, block is the html to evaluate
  def assert_has_tag(name, attributes = {}, &block)
    html = block && block.call
    asserts("match #{name} with #{attributes.inspect}") { HaveSelector.new(name, attributes).matches?(html) }
  end

  def assert_match(matchee, pattern)
    pattern = pattern.is_a?(String) ? Regexp.new(Regexp.escape(pattern)) : pattern
    asserts("#{matchee} matches #{pattern}") { matchee =~ pattern}
  end
  
  def assert_no_match(matchee, pattern)
    assert_match(matchee, pattern).not!
  end

  # assert_file_exists('/tmp/app')
  def assert_file_exists(file_path)
    asserts("#{file_path}") { File.exists?(file_path) }
  end
  alias :assert_dir_exists :assert_file_exists

  def assert_no_file_exists(file_path)
    assert_file_exists(file_path).not!
  end
  alias :assert_no_dir_exists :assert_no_file_exists

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    File.exist?(file) ? assert_match(File.read(file), pattern) : assert_file_exists(file)
  end
  
  def assert_no_match_in_file(pattern, file)
    assert_match_in_file(pattern, file).not!
  end
  
end

class Object
  # Silences the output by redirecting to stringIO
  # silence_logger { ...commands... } => "...output..."
  def silence_logger(&block)
    orig_stdout = $stdout
    $stdout = log_buffer = StringIO.new
    block.call
    $stdout = orig_stdout
    log_buffer.rewind && log_buffer.read
  end
end

module Webrat
  module Logging
    def logger # :nodoc:
      @logger = nil
    end
  end
end
