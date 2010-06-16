require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'padrino-gen/generators/cli'

context "Cli" do
  clean_up!

  context "fails without arguments" do
    setup { silence_logger { generate(:cli) } }
    asserts_topic.matches %r{Please specify generator to use}
  end

  context "work correctly if we have a project" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp') } }
    asserts("no raise") { silence_logger { generate(:cli, '--root=/tmp/sample_project') } }
  end
end
