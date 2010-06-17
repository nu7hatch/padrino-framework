require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/simple')

context "Simple Reloader" do

  context "reset" do
    setup do
      mock_app do
        (1..10).each { |i| get("/#{i}") { "Foo #{i}" } }
      end
    end
    (1..10).each { |i| asserts("/#{i}") { get "/#{i}" ; body }.equals "Foo #{i}" }

    context "after reset" do
      setup { @app.reset_routes! }
      (1..10).each { |i| asserts("/#{i}") { get "/#{i}" ; status }.equals 404 }
    end

  end

  context "keep sinatra routes on development" do
    setup do
      mock_app do
        set :environment, :development
        get("/") { 'ok' }
      end
    end
    asserts(:environment).equals :development
    asserts("/") { get "/" ; status }.equals 200
    asserts("sinatra 404") {  get "/__sinatra__/404.png" ; status }.equals 200
    asserts("content type") { get "/__sinatra__/404.png" ; response["Content-Type"] }.equals 'image/png'

    context "reset!" do
      setup { @app.reset_routes! }
      asserts("/") { get "/" ; status }.equals 404
      asserts("sinatra 404") {  get "/__sinatra__/404.png" ; status }.equals 200
      asserts("content type") { get "/__sinatra__/404.png" ; response["Content-Type"] }.equals 'image/png'
    end

  end

  context "reload" do

    context "instantiate SimpleDemo fixture" do
      setup { Padrino.mounted_apps.clear }
      setup { Padrino.mount_core("simple_demo") }
      asserts("app names") { Padrino.mounted_apps.collect(&:name) }.equals ['core']
      asserts("reloads") { SimpleDemo.reload? }
      asserts("file") { SimpleDemo.app_file }.matches %r{fixtures/apps/simple.rb}
    end

    context "reload SimpleDemo fixture" do
      setup { @app = SimpleDemo }
      asserts("/") { get '/' ; ok? }

      context "rewrite" do
        setup do
          @buffer = File.read(SimpleDemo.app_file)
          new_buffer = @buffer.gsub(/The magick number is: \d+!/, "The magick number is: 12345!")
          File.open(SimpleDemo.app_file, "w") { |f| f.write(new_buffer) }
          sleep 1.2 # We need at least a cooldown of 1 sec.
        end
        teardown do
          # Now we need to prevent to commit a new changed file so we revert it
          File.open(SimpleDemo.app_file, "w") { |f| f.write(@buffer) }
          Padrino.reload!
        end        
        asserts("returns right body") { get '/'; body }.equals "The magick number is: 12345!"
      end

    end
  
    context "reset SimpleDemo fixture" do
      setup { @app = SimpleDemo }
      asserts("/rand") { get '/rand' ; @last = body; ok? }
      asserts(:before_filters).size 2 # one is ours the other is default_filter for content type
      asserts(:errors).size 1
      asserts(:after_filters).size 1
      asserts(:middleware).size 2 # [Padrino::Logger::Rack, Padrino::Reloader::Rack]
      asserts(:routes).size 4 # GET+HEAD of "/" + GET+HEAD of "/rand" = 4
      asserts(:extensions).size 2 # [Padrino::Routing, Padrino::Rendering]
      asserts(:templates).size 0
      
      context "reload!" do
        setup { @app.reload! ; @app }
        asserts("/rand") { get '/rand' ; @last != body }
        asserts(:before_filters).size 2 # one is ours the other is default_filter for content type
        asserts(:errors).size 1
        asserts(:after_filters).size 1
        asserts(:middleware).size 2 # [Padrino::Logger::Rack, Padrino::Reloader::Rack]
        asserts(:routes).size 4 # GET+HEAD of "/" + GET+HEAD of "/rand" = 4
        asserts(:extensions).size 2 # [Padrino::Routing, Padrino::Rendering]
        asserts(:templates).size 0
      end
      
    end
  
  end

end