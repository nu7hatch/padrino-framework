require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Padrino Logger" do
  setup do
    Padrino::Logger::Config[:test][:stream] = :null # The default
    Padrino::Logger.setup!
  end

  context 'stream configuration' do
    context "default" do
      setup { Padrino.logger.log }
      asserts_topic.kind_of StringIO
    end

    context 'if stream is nil' do
      setup do
        Padrino::Logger::Config[:test][:stream] = nil
        Padrino::Logger.setup!
        Padrino.logger.log
      end
      asserts_topic.equals $stdout
    end

    asserts 'using custom stream' do
      my_stream = StringIO.new
      Padrino::Logger::Config[:test][:stream] = my_stream
      Padrino::Logger.setup!
      my_stream == Padrino.logger.log
    end
  end

  context "logging" do
    context "something" do
      setup do
        @log = StringIO.new
        Padrino::Logger.new(:log_level => :error, :stream => @log)
      end
      asserts("logging debug") { topic.debug "You dont log!" ; @log.string =~ %r{You dont log!}}.not!
      asserts("logging error") { topic.error "log error!"; @log.string }.matches  %r{log error!}
      asserts("logging it") { topic<<("This too") ; @log.string }.matches %r{This too}
    end

    context 'application' do
      setup do
        mock_app { get("/"){ "Foo" } }
        get "/"
      end
      asserts("foo") { body }.equals "Foo"
      asserts("GET 200") { Padrino.logger.log.string }.matches %r{GET \/  - 200}
    end
  end
end
