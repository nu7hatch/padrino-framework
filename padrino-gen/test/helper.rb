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

  # assert_has_tag(:h1, :content => "yellow") { "<h1>yellow</h1>" }
  # In this case, block is the html to evaluate
  def assert_has_tag(name, attributes = {}, &block)
    html = block && block.call
    asserts("match #{name} with #{attributes.inspect}") { HaveSelector.new(name, attributes).matches?(html) }
  end

  # assert_file_exists('/tmp/app')
  def assert_file_exists(file_path)
    asserts("#{file_path}") { File.exists?(file_path) }
  end
  alias :assert_dir_exists :assert_file_exists

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    asserts "#{file} has pattern #{pattern}" do
      File.exist?(file) ? File.read(file) =~ pattern : assert_file_exists(file)    
    end
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
