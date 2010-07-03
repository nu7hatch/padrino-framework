require File.expand_path("../../padrino-core/lib/padrino-core/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{padrino-mailer}
  s.rubyforge_project = %q{padrino-mailer}
  s.authors = ["Padrino Team", "Nathan Esquenazi", "Davide D'Agostino", "Arthur Chiu"]
  s.email = %q{padrinorb@gmail.com}
  s.summary = %q{Mailer system for padrino}
  s.homepage = %q{http://github.com/padrino/padrino-framework/tree/master/padrino-mailer}
  s.description = %q{Mailer system for padrino allowing easy delivery of application emails}
  s.required_rubygems_version = ">= 1.3.6"
  s.version = Padrino.version
  s.date = Time.now.strftime("%Y-%m-%d")
  s.extra_rdoc_files = Dir["*.rdoc"]
  s.files = %w(.document .gitignore LICENSE README.rdoc Rakefile padrino-mailer.gemspec) + Dir.glob("{bin,lib,test}/**/*")
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = 'lib'
  s.add_runtime_dependency("padrino-core", "= #{Padrino.version}")
  s.add_runtime_dependency("mail", ">= 2.2.0")
  s.add_runtime_dependency("tlsmail") if RUBY_VERSION == "1.8.6"
  s.add_development_dependency("rake", ">= 0.8.7")
  s.add_development_dependency("mocha", ">= 0.9.8")
  s.add_development_dependency("rack-test", ">= 0.5.0")
  s.add_development_dependency("fakeweb",  ">=1.2.8")
  s.add_development_dependency("webrat", ">= 0.5.1")
  s.add_development_dependency("haml", ">= 2.2.22")
  s.add_development_dependency("shoulda", ">= 2.10.3")
end