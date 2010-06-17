require File.expand_path(File.dirname(__FILE__) + '/helper')

class PadrinoTestApp < Padrino::Application; end

context "Application" do
  teardown { remove_views }

  context "default options" do
    setup { PadrinoTestApp }
    asserts("identical files") { File.identical?(__FILE__, PadrinoTestApp.app_file) }
    asserts(:app_name).equals :padrino_test_app
    asserts(:environment).equals :test
    asserts(:views) { PadrinoTestApp.views }.equals Padrino.root('views')
    asserts(:raise_errors)
    asserts(:logging).not!
    asserts(:sessions).not!
  end

  context "padrino specific options" do
    asserts("configured before setup") { PadrinoTestApp.instance_variable_get(:@_configured) }.not!

    context "setup!" do
      setup { PadrinoTestApp.send(:setup_application!) ; PadrinoTestApp }
      asserts(:app_name).equals :padrino_test_app
      asserts(:default_builder).equals 'StandardFormBuilder'
      asserts("configured after setup") { PadrinoTestApp.instance_variable_get(:@_configured) }
      asserts(:reload?).not!
      asserts(:flash).not!
    end
  end

  context "content_type defaults to html" do
    setup do
      mock_app do
        provides :xml
        get("/foo"){ "Foo in #{content_type}" }
        get("/bar"){ "Foo in #{content_type}" }
      end
    end

    context "/foo" do
      context "with xml" do
        setup { get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' } }
        asserts("xml") { body }.equals 'Foo in xml'
      end

      context "with none" do
        setup { get '/foo' }
        asserts("not found") { not_found? }
      end
    end

    context "/bar" do
      setup { get '/bar', {}, { 'HTTP_ACCEPT' => 'application/xml' } }
      asserts("html") { body }.equals "Foo in html"
    end
  end

end