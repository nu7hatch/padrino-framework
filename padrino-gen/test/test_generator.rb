require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Generators" do
   %w{controller mailer migration model app}.each do |gen|
    context "has #{gen}" do
      asserts("in mappings") { Padrino::Generators.mappings.has_key?(gen.to_sym) }
      asserts("namespace") { Padrino::Generators.mappings[gen.to_sym].name }.equals "Padrino::Generators::#{gen.classify}"
      asserts("start") { Padrino::Generators.mappings[gen.to_sym] }.respond_to :start
    end
   end
end