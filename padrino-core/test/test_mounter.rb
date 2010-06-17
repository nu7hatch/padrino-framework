require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Mounter" do
  setup { Padrino.mounted_apps.clear }

  context "methods" do
    setup { Padrino::Mounter.new("test", :app_file => "/path/to/test.rb").to("/test") }
    asserts("new") { Padrino::Mounter }.responds_to :new
    asserts_topic.kind_of Padrino::Mounter
    asserts_topic.responds_to :to
    asserts_topic.responds_to :map_onto
    asserts(:name).equals "test"
    asserts(:app_class).equals "Test"
    asserts(:app_file).equals "/path/to/test.rb"
    asserts(:uri_root).equals "/test"
    asserts(:app_root).equals "/path/to"
  end

  context "locate_app_file with __FILE__" do
    setup { Padrino::Mounter.new("test", :app_file => __FILE__).to("/test") }
    asserts(:name).equals "test"
    asserts(:app_class).equals "Test"
    asserts(:app_file).equals __FILE__
    asserts(:uri_root).equals "/test"
    asserts(:app_root).equals File.dirname(__FILE__)
  end

  context "mounting" do

    context "an app" do
      class ::AnApp < Padrino::Application; end
      setup { Padrino.mount_core("an_app") }
      asserts("app object") { Padrino.mounted_apps.first.app_obj }.equals AnApp
      asserts("app names") { Padrino.mounted_apps.collect(&:name) }.equals ["core"]
    end

    context "a core" do
      setup { Padrino.mount_core("test", :app_file => __FILE__) }
      asserts(:name).equals 'core'
      asserts(:app_class).equals 'Test'
      asserts(:app_obj).equals Test
      asserts(:app_file).equals __FILE__
      asserts(:uri_root).equals "/"
      asserts(:app_root).equals File.dirname(__FILE__)
    end

    context "a core to url" do
      setup { Padrino.mount_core("test", :app_file => __FILE__).to('/me') }
      asserts(:name).equals 'core'
      asserts(:app_class).equals 'Test'
      asserts(:app_file).equals __FILE__
      asserts(:uri_root).equals '/me'
      asserts(:app_root).equals File.dirname(__FILE__)
    end

    context "multiple apps" do
      class ::OneApp < Padrino::Application; end
      class ::TwoApp < Padrino::Application; end
      setup do
        Padrino.mount("one_app").to("/one_app")
        Padrino.mount("two_app").to("/two_app")
        # And testing no duplicates
        Padrino.mount("one_app").to("/one_app")
        Padrino.mount("two_app").to("/two_app")
      end

      asserts("first app") { Padrino.mounted_apps[0].app_obj }.equals OneApp
      asserts("second app") { Padrino.mounted_apps[1].app_obj }.equals TwoApp
      asserts("no dups") { Padrino.mounted_apps }.size 2
      asserts("app names") { Padrino.mounted_apps.collect(&:name) }.equivalent_to ["one_app", "two_app"]
    end

  end

  context "changing mounted_root" do
    context "to fixtures" do
      setup { Padrino.mounted_root = "fixtures" ; Padrino.mounted_root("test", "app.rb") }
      asserts_topic.equals Padrino.root("fixtures", "test", "app.rb")
    end
    context "to apps" do
      setup { Padrino.mounted_root = "apps" ; Padrino.mounted_root("test", "app.rb") }
      asserts_topic.equals Padrino.root("apps", "test", "app.rb")
    end
    context "to nil" do
      setup { Padrino.mounted_root = nil ; Padrino.mounted_root("test", "app.rb") }
      asserts_topic.equals Padrino.root("test", "app.rb")
    end
  end

  context "instantiate a new padrino application" do
    setup do
      mock_app do
        get("/demo_1"){ "Im Demo 1" }
        get("/demo_2"){ "Im Demo 2" }
      end
    end
    context "/demo_1" do
      setup { get '/demo_1' ; body }
      asserts_topic.equals 'Im Demo 1'
    end
    context "/demo_2" do
      setup { get '/demo_2' ; body }
      asserts_topic.equals 'Im Demo 2'
    end
  end

end