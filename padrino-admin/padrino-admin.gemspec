require File.expand_path("../../padrino-core/lib/padrino-core/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{padrino-admin}
  s.rubyforge_project = %q{padrino-admin}
  s.authors = ["Padrino Team", "Nathan Esquenazi", "Davide D'Agostino", "Arthur Chiu"]
  s.email = %q{padrinorb@gmail.com}
  s.summary = %q{Admin Dashboard for Padrino}
  s.homepage = %q{http://github.com/padrino/padrino-framework/tree/master/padrino-admin}
  s.description = %q{Admin View for Padrino applications}
  s.required_rubygems_version = ">= 1.3.6"
  s.version = Padrino.version
  s.date = Time.now.strftime("%Y-%m-%d")
  s.extra_rdoc_files = Dir["*.rdoc"]
  s.files = %w(.document .gitignore LICENSE README.rdoc Rakefile padrino-admin.gemspec) + Dir.glob("{bin,lib,test}/**/*")
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = 'lib'
  s.add_runtime_dependency("padrino-gen", "= #{Padrino.version}")
  s.add_runtime_dependency("padrino-helpers", "= #{Padrino.version}")
  s.add_runtime_dependency("padrino-core", "= #{Padrino.version}")
  s.add_development_dependency("rake", ">= 0.8.7")
  s.add_development_dependency("mocha", ">= 0.9.8")
  s.add_development_dependency("rack-test", ">= 0.5.0")
  s.add_development_dependency("fakeweb",  ">=1.2.8")
  s.add_development_dependency("webrat", ">= 0.5.1")
  s.add_development_dependency("haml", ">= 2.2.22")
  s.add_development_dependency("shoulda", ">= 2.10.3")
end