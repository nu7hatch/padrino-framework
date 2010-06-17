require File.expand_path(File.dirname(__FILE__) + '/helper')

class PadrinoTestApp < Padrino::Application; end

context "Application" do
  teardown { remove_views }

  context "default options" do
    asserts("identical files") { File.identical?(__FILE__, PadrinoTestApp.app_file) }
    asserts("app name") { PadrinoTestApp.app_name }.equals :padrino_test_app
    asserts("environment") { PadrinoTestApp.environment }.equals :test
    asserts("views") { PadrinoTestApp.views }.equals Padrino.root('views')
    asserts("raise errors enabled") { PadrinoTestApp.raise_errors }
    asserts("logging enabled") { PadrinoTestApp.logging }.not!
    asserts("sessions enabled") { PadrinoTestApp.sessions }.not!
  end

  context "padrino specific options" do
    asserts("configured before setup") { PadrinoTestApp.instance_variable_get(:@_configured) }.not!

    context "setup!" do
      setup { PadrinoTestApp.send(:setup_application!) }
      asserts("app name") { PadrinoTestApp.app_name }.equals :padrino_test_app
      asserts("default builder") { PadrinoTestApp.default_builder }.equals 'StandardFormBuilder'
      asserts("configured after setup") { PadrinoTestApp.instance_variable_get(:@_configured) }
      asserts("reload?") { PadrinoTestApp.reload? }.not!
      asserts("flash enabled") { PadrinoTestApp.flash }.not!
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