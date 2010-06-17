require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/complex')

context "Complex Reloader" do

  context "instantiate Complex(1-2)Demo fixture" do
    setup do
      Padrino.mounted_apps.clear
      Padrino.mount("complex_1_demo").to("/complex_1_demo")
      Padrino.mount("complex_2_demo").to("/complex_2_demo")
    end
    asserts("correct uri roots") { Padrino.mounted_apps.collect(&:uri_root) }.equals ["/complex_1_demo", "/complex_2_demo"]
    asserts("correct names") { Padrino.mounted_apps.collect(&:name) }.equals ["complex_1_demo", "complex_2_demo"]
    asserts("first reloads") { Complex1Demo.reload? }
    asserts("second reloads") { Complex2Demo.reload? }
    asserts("correct file for 1Demo") { Complex1Demo.app_file }.matches %r{fixtures/apps/complex.rb}
    asserts("correct file for 2Demo") { Complex2Demo.app_file }.matches %r{fixtures/apps/complex.rb}

    context "reloading demo fixture" do
      setup { @app = Padrino.application }

      asserts("/ status") { get "/" ; status }.equals 404
      asserts("Complex1Demo body") { get "/complex_1_demo" ; body }.equals "Given random #{LibDemo.give_me_a_random}"
      asserts("Complex2Demo status") { get "/complex_2_demo" ; status }.equals 200
      asserts("Complex1Demo old status") { get "/complex_1_demo/old" ; status }.equals 200
      asserts("Complex2Demo old status") { get "/complex_2_demo/old" ; status }.equals 200

      context "rewrite" do
        setup do
          @buffer = File.read(Complex1Demo.app_file)
          new_buffer = @buffer.gsub(/The magick number is: \d+!/, "The magick number is: 123456!")
          File.open(Complex1Demo.app_file, "w") { |f| f.write(new_buffer) }
          sleep 1.2 # We need at least a cooldown of 1 sec.
        end
        teardown { File.open(Complex1Demo.app_file, "w") { |f| f.write(@buffer) } }
        asserts("Complex2Demo body") { get "/complex_2_demo" ; body }.equals "The magick number is: 123456!"
        asserts("Complex1Demo body") { get "/complex_1_demo" ; body }.equals "Given random #{LibDemo.give_me_a_random}"
        asserts("Complex2Demo status") { get "/complex_2_demo" ; status }.equals 200
        asserts("Complex1Demo old status") { get "/complex_1_demo/old" ; status }.equals 200
        asserts("Complex2Demo old status") { get "/complex_2_demo/old" ; status }.equals 200
      end
    end

  end
end