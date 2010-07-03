require File.expand_path("../padrino-core/lib/padrino-core/version.rb", __FILE__)
require File.expand_path("../lib/ext/bundler.rb", __FILE__)

source :rubygems

# padrino-core dependencies
gemspec :path => File.expand_path('../padrino-core', __FILE__), :development_group => 'core'
group :core do
  # If you want try our test on AS edge.
  # $ AS=edge bundle install
  # $ AS=edge rake test
  if ENV['AS'] == "edge"
    puts "Using ActiveSupport 3.0.0.beta4"
    gem "activesupport", ">= 3.0.0.beta4"
    gem "tzinfo"
  end
end

gemspec :path => File.expand_path('../padrino-admin', __FILE__), :development_group => 'admin'
gemspec :path => File.expand_path('../padrino-cache', __FILE__), :development_group => 'cache'
gemspec :path => File.expand_path('../padrino-gen', __FILE__), :development_group => 'gen'
gemspec :path => File.expand_path('../padrino-helpers', __FILE__), :development_group => 'helpers'
gemspec :path => File.expand_path('../padrino-mailer', __FILE__), :development_group => 'mailer'

group :db do
  gem "dm-core", ">= 1.0"
  gem "dm-migrations", ">= 1.0"
  gem "dm-validations", ">= 1.0"
  gem "dm-aggregates", ">= 1.0"
  gem "dm-sqlite-adapter", ">= 1.0"
end