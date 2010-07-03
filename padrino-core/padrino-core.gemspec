require File.expand_path("../lib/padrino-core/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = "padrino-core"
  s.rubyforge_project = "padrino-core"
  s.authors = ["Padrino Team", "Nathan Esquenazi", "Davide D'Agostino", "Arthur Chiu"]
  s.email = %q{padrinorb@gmail.com}
  s.summary = %q{The required Padrino core gem}
  s.homepage = "http://github.com/padrino/padrino-framework/tree/master/padrino-core"
  s.description = %q{The Padrino core gem required for use of this framework}
  s.default_executable = %q{padrino}
  s.executables = ["padrino"]
  s.required_rubygems_version = ">= 1.3.6"
  s.version = Padrino.version
  s.date = Time.now.strftime("%Y-%m-%d")
  s.extra_rdoc_files = Dir["*.rdoc"]
  s.files = %w(.document .gitignore LICENSE README.rdoc Rakefile padrino-core.gemspec) + Dir.glob("{bin,lib,test}/**/*")
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = 'lib'
  s.add_runtime_dependency("sinatra", ">= 1.0.0")
  s.add_runtime_dependency("http_router", ">= 0.3.0")
  s.add_runtime_dependency("thor", ">= 0.13.0")
  s.add_runtime_dependency("activesupport", ">= 2.3.8")
  s.add_runtime_dependency("builder", ">= 2.1.2")
  s.add_development_dependency("rake", ">= 0.8.7")
  s.add_development_dependency("mocha", ">= 0.9.8")
  s.add_development_dependency("rack-test", ">= 0.5.0")
  s.add_development_dependency("fakeweb",  ">=1.2.8")
  s.add_development_dependency("webrat", ">= 0.5.1")
  s.add_development_dependency("haml", ">= 2.2.22")
  s.add_development_dependency("shoulda", ">= 2.10.3")
end