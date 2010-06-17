require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Dependencies" do

  context "requiring dependencies with their own dependency" do

    context "will raise an error without padrino" do
      asserts "requires" do
        require "fixtures/dependencies/a.rb"
        require "fixtures/dependencies/b.rb"
        require "fixtures/dependencies/c.rb"
      end.raises NameError
    end

    context "resolve the dependency problem" do
      setup do
        silence_warnings do
          Padrino.require_dependencies(
            Padrino.root("fixtures/dependencies/a.rb"),
            Padrino.root("fixtures/dependencies/b.rb"),
            Padrino.root("fixtures/dependencies/c.rb"))
        end
      end
      asserts("A Result") { A_result }.equals ['B','A']
      asserts("B Result") { B_result }.equals ['C','B']
      
    end

  end
end
