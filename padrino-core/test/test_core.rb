require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Core" do

  context "global methods" do
    setup { Padrino }
    asserts_topic.respond_to :root
    asserts_topic.respond_to :env
    asserts_topic.respond_to :application
    asserts_topic.respond_to :set_encoding
    asserts_topic.respond_to :load!
    asserts_topic.respond_to :reload!
    asserts_topic.respond_to :version
    asserts_topic.respond_to :bundle
  end

  context "global helpers" do
    setup { Padrino }
    asserts("env") { topic.env }.equals :test
    asserts("root") { topic.root }.matches %r{test}
    asserts("bundle") { topic.bundle }.nil
    asserts("version") { topic.version }.exists
  end

  context "encoding" do
    setup { Padrino.set_encoding }
    if RUBY_VERSION < '1.9'
      asserts("utf8") { $KCODE }.equals('UTF8')
    end
  end

  context "load paths" do
    setup { Padrino.load_paths }
    asserts_topic.equivalent_to [Padrino.root('lib'), Padrino.root('models'), Padrino.root('shared')]
  end

  context 'I instantiate a new padrino application without mounted apps' do
    setup { Padrino.mounted_apps.clear }
    asserts("will raise error") { Padrino.application.new }.raises Padrino::ApplicationLoadError
  end

end