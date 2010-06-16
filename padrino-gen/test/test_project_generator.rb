require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Project Generator" do
  clean_up!

  context "component options" do

    context "components file with default options" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp') }
        YAML.load_file('/tmp/sample_project/.components')
      end
      asserts("orm") { topic[:orm] }.equals 'none'
      asserts("test") { topic[:test] }.equals 'none'
      asserts("mock") { topic[:mock] }.equals 'none'
      asserts("script") { topic[:script] }.equals 'none'
      asserts("renderer") { topic[:renderer] }.equals 'haml'
      asserts("stylesheet") { topic[:stylesheet] }.equals 'none'
    end

    context "components file containing options chosen" do
      setup do
        component_options = ['--orm=datamapper', '--test=riot', '--mock=mocha', '--script=prototype', '--renderer=erb', '--stylesheet=less']
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', *component_options) }
        YAML.load_file('/tmp/sample_project/.components')
      end
      asserts("orm") { topic[:orm] }.equals 'datamapper'
      asserts("test") { topic[:test] }.equals 'riot'
      asserts("mock") { topic[:mock] }.equals 'mocha'
      asserts("script") { topic[:script] }.equals 'prototype'
      asserts("renderer") { topic[:renderer] }.equals 'erb'
      asserts("stylsheet") { topic[:stylesheet] }.equals 'less'
    end

    context "allow no options" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp') } }
      assert_file_exists '/tmp/sample_project'
      assert_match_in_file %r{class SampleProject < Padrino::Application},'/tmp/sample_project/app/app.rb'
      assert_match_in_file %r{Padrino.mount_core\("SampleProject"\)},'/tmp/sample_project/config/apps.rb'
      assert_file_exists '/tmp/sample_project/config/boot.rb'
      assert_file_exists '/tmp/sample_project/public/favicon.ico'
    end
  end

  context "allow alternate application name" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--app=base_app') } }
    assert_file_exists '/tmp/sample_project'
    assert_match_in_file %r{class BaseApp < Padrino::Application},'/tmp/sample_project/app/app.rb'
    assert_match_in_file %r{Padrino.mount_core\("BaseApp"\)},'/tmp/sample_project/config/apps.rb'
    assert_file_exists '/tmp/sample_project/config/boot.rb'
    assert_file_exists '/tmp/sample_project/public/favicon.ico'
  end

  context "generates tiny skeleton" do
    setup { silence_logger { generate(:project,'sample_project', '--tiny','--root=/tmp') } }
    assert_file_exists '/tmp/sample_project'
    assert_file_exists '/tmp/sample_project/app'
    assert_file_exists '/tmp/sample_project/app/controllers.rb'
    assert_file_exists '/tmp/sample_project/app/helpers.rb'
    assert_file_exists '/tmp/sample_project/app/mailers.rb'
    assert_dir_exists '/tmp/sample_project/app/views/mailers'
    assert_match_in_file %r{:notifier},'/tmp/sample_project/app/mailers.rb'
    assert_no_file_exists '/tmp/sample_project/demo/helpers'
    assert_no_file_exists '/tmp/sample_project/demo/controllers'
  end

  context "no models if no orm chosen" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '--orm=none') } }
    assert_no_dir_exists '/tmp/sample_project/app/models'
  end

  context "not create tests folder if no test framework is chosen" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '--test=none') } }
    assert_no_dir_exists '/tmp/sample_project/test'
  end

  context "place app specific names into correct files" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none') } }
    assert_match_in_file %r{class SampleProject < Padrino::Application}, '/tmp/sample_project/app/app.rb'
    assert_match_in_file %r{Padrino.mount_core\("SampleProject"\)}, '/tmp/sample_project/config/apps.rb'
  end

  context "output logs components applied" do
    setup do
      component_options = ['--orm=datamapper', '--test=riot', '--mock=mocha', '--script=prototype', '--renderer=erb','--stylesheet=less']
      silence_logger { generate(:project, 'sample_project', '--root=/tmp', *component_options) }
    end
    asserts_topic.matches %r{Applying.*?datamapper.*?orm}
    asserts_topic.matches %r{Applying.*?riot.*?test}
    asserts_topic.matches %r{Applying.*?mocha.*?mock}
    asserts_topic.matches %r{Applying.*?prototype.*?script}
    asserts_topic.matches %r{Applying.*?erb.*?renderer}
    asserts_topic.matches %r{Applying.*?less.*?stylesheet}
  end

  context "output gem files for base app" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none') } }
    assert_match_in_file %r{gem 'padrino'}, '/tmp/sample_project/Gemfile'
    assert_match_in_file %r{gem 'rack-flash'}, '/tmp/sample_project/Gemfile'
    assert_match_in_file %r{gem 'thin'}, '/tmp/sample_project/Gemfile'
  end

  context "mock components" do

    context "rr and riot" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--mock=rr', '--test=riot', '--script=none') } }
      asserts_topic.matches %r{Applying.*?rr.*?mock}
      assert_match_in_file %r{gem 'rr'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{require 'riot\/rr'}, '/tmp/sample_project/test/test_config.rb'
    end

    context "rr and bacon" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--mock=rr', '--test=bacon', '--script=none') } }
      asserts_topic.matches %r{Applying.*?rr.*?mock}
      assert_match_in_file %r{gem 'rr'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{RR::Adapters::RRMethods}, '/tmp/sample_project/test/test_config.rb'
    end

    context "mocha and rspec" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp','--test=rspec', '--mock=mocha', '--script=none') } }
      asserts_topic %r{Applying.*?mocha.*?mock}
      assert_match_in_file %r{gem 'mocha'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{conf.mock_with :mocha}, '/tmp/sample_project/spec/spec_helper.rb'
    end

    context "rr and rspec" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=rspec', '--mock=rr', '--script=none') } }
      asserts_topic %r{Applying.*?rr.*?mock}
      assert_match_in_file %r{gem 'rr'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{conf.mock_with :rr}, '/tmp/sample_project/spec/spec_helper.rb'
    end

  end

  context "orm components" do

    context "sequel" do

      context "generate default" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=sequel', '--script=none') } }
        asserts_topic.matches %r{Applying.*?sequel.*?orm}
        assert_match_in_file %r{gem 'sequel'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{gem 'sqlite3-ruby'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{Sequel.connect}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{sqlite://}, '/tmp/sample_project/config/database.rb'
        assert_dir_exists '/tmp/sample_project/app/models'
      end

      context "generate mysql" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=sequel', '--adapter=mysql') } }
        assert_match_in_file %r{gem 'mysql'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{"mysql://}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
      end

      context "generate sqlite3" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=sequel', '--adapter=sqlite') } }
        assert_match_in_file %r{gem 'sqlite3-ruby'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{sqlite://}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
      end

      context "generate postgres" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=sequel', '--adapter=postgres') } }
        assert_match_in_file %r{gem 'pg'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{"postgres://}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
      end
    end

    context "activerecord" do

      context "generate default" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=activerecord', '--script=none') } }
        asserts_topic.matches %r{Applying.*?activerecord.*?orm}
        assert_match_in_file %r{gem 'activerecord', :require => "active_record"}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{gem 'sqlite3-ruby', :require => "sqlite3"}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{ActiveRecord::Base.establish_connection}, '/tmp/sample_project/config/database.rb'
        assert_dir_exists '/tmp/sample_project/app/models'
      end

      context "generate mysql" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=activerecord','--adapter=mysql') } }
        assert_match_in_file %r{gem 'mysql'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{:adapter   => 'mysql'}, '/tmp/sample_project/config/database.rb'
      end

      context "properly generate sqlite3" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=activerecord', '--adapter=sqlite3') } }
        assert_match_in_file %r{gem 'sqlite3-ruby', :require => "sqlite3"}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{sample_project_development.db}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{:adapter => 'sqlite3'}, '/tmp/sample_project/config/database.rb'
      end

      context "properly generate postgres" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=activerecord', '--adapter=postgres') } }
        assert_match_in_file %r{gem 'pg', :require => "postgres"}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{:adapter   => 'postgresql'}, '/tmp/sample_project/config/database.rb'
      end
    end

    context "datamapper" do

      context "generate default" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=datamapper', '--script=none') } }
        asserts_topic.matches %r{Applying.*?datamapper.*?orm}
        assert_match_in_file %r{gem 'data_mapper'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{gem 'dm-sqlite-adapter'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{DataMapper.setup}, '/tmp/sample_project/config/database.rb'
        assert_dir_exists '/tmp/sample_project/app/models'
      end

      context "generate mysql" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=datamapper', '--adapter=mysql') } }
        assert_match_in_file %r{gem 'dm-mysql-adapter'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{"mysql://}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
      end

      context "generate sqlite" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=datamapper', '--adapter=sqlite') } }
        assert_match_in_file %r{gem 'dm-sqlite-adapter'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
      end

      context "generate postgres" do
        setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=datamapper', '--adapter=postgres') } }
        assert_match_in_file %r{gem 'dm-postgres-adapter'}, '/tmp/sample_project/Gemfile'
        assert_match_in_file %r{"postgres://}, '/tmp/sample_project/config/database.rb'
        assert_match_in_file %r{sample_project_development}, '/tmp/sample_project/config/database.rb'
      end
    end

    context "mongomapper" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=mongomapper', '--script=none') } }
      asserts_topic.matches %r{Applying.*?mongomapper.*?orm}
      assert_match_in_file %r{gem 'mongo_mapper'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{MongoMapper.database}, '/tmp/sample_project/config/database.rb'
      assert_dir_exists '/tmp/sample_project/app/models'
    end

    context "mongoid" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=mongoid', '--script=none') } }
      asserts_topic.matches %r{Applying.*?mongoid.*?orm}
      assert_match_in_file %r{gem 'mongoid'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{Mongoid.database}, '/tmp/sample_project/config/database.rb'
      assert_dir_exists '/tmp/sample_project/app/models'
    end

    context "couchrest" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--orm=couchrest', '--script=none') } }
      asserts_topic.matches %r{Applying.*?couchrest.*?orm}
      assert_match_in_file %r{gem 'couchrest'}, '/tmp/sample_project/Gemfile'
      assert_match_in_file %r{CouchRest.database!}, '/tmp/sample_project/config/database.rb'
      assert_dir_exists '/tmp/sample_project/app/models'
    end

  end

  context "renderer components" do

    context "erb" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--renderer=erb', '--script=none') } }
      asserts_topic.matches %r{Applying.*?erb.*?renderer}
    end

    context "haml" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--renderer=haml','--script=none') } }
      asserts_topic.matches %r{Applying.*?haml.*?renderer}
      assert_match_in_file %r{gem 'haml'}, '/tmp/sample_project/Gemfile'
    end
  end

  context "script component" do

    context "properly generate for jquery" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=jquery') } }
      asserts_topic.matches %r{Applying.*?jquery.*?script}
      assert_file_exists '/tmp/sample_project/public/javascripts/jquery.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/application.js'
    end

    context "properly generate for mootools" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=mootools') } }
      asserts_topic.matches %r{Applying.*?mootools.*?script}
      assert_file_exists '/tmp/sample_project/public/javascripts/mootools-core.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/application.js'
    end

    context "properly generate for prototype" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=prototype') } }
      asserts_topic.matches %r{Applying.*?prototype.*?script}
      assert_file_exists '/tmp/sample_project/public/javascripts/protopak.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/lowpro.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/application.js'
    end

    context "properly generate for rightjs" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=rightjs') } }
      asserts_topic.matches %r{Applying.*?rightjs.*?script}
      assert_file_exists '/tmp/sample_project/public/javascripts/right.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/application.js'
    end

    context "properly generate for ext-core" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=extcore') } }
      asserts_topic.matches %r{Applying.*?extcore.*?script}
      assert_file_exists '/tmp/sample_project/public/javascripts/ext-core.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/application.js'
    end

    context "properly generate for dojo" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=dojo') } }
      asserts_topic.matches %r{Applying.*?dojo.*?script}
      assert_file_exists '/tmp/sample_project/public/javascripts/dojo.js'
      assert_file_exists '/tmp/sample_project/public/javascripts/application.js'
    end
  end

  context "test component" do

    context "bacon" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=bacon', '--script=none') } }
      asserts_topic.matches %r{Applying.*?bacon.*?test}
      assert_match_in_file(/gem 'rack-test'.*?:require => "rack\/test".*?:group => "test"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'bacon'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/Bacon::Context/, '/tmp/sample_project/test/test_config.rb')
      assert_file_exists('/tmp/sample_project/test/test.rake')
    end

    context "riot" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=riot', '--script=none') } }
      asserts_topic.matches %r{Applying.*?riot.*?test}
      assert_match_in_file(/gem 'rack-test'.*?:require => "rack\/test".*?:group => "test"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'riot'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/include Rack::Test::Methods/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/Riot::Situation/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/Riot::Context/, '/tmp/sample_project/test/test_config.rb')
      assert_file_exists('/tmp/sample_project/test/test.rake')
    end

    context "rspec" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=rspec', '--script=none') } }
      asserts_topic.matches %r{Applying.*?rspec.*?test}
      assert_match_in_file(/gem 'rack-test'.*?:require => "rack\/test".*?:group => "test"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'rspec'.*?:require => "spec"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/spec/spec_helper.rb')
      assert_match_in_file(/Spec::Runner/, '/tmp/sample_project/spec/spec_helper.rb')
      assert_file_exists('/tmp/sample_project/spec/spec.rake')
    end

    context "shoulda" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=shoulda', '--script=none') } }
      asserts_topic.matches %r{Applying.*?shoulda.*?test}
      assert_match_in_file(/gem 'rack-test'.*?:require => "rack\/test".*?:group => "test"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'shoulda'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/Test::Unit::TestCase/, '/tmp/sample_project/test/test_config.rb')
      assert_file_exists('/tmp/sample_project/test/test.rake')
    end

    context "testspec" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=testspec', '--script=none') } }
      asserts_topic.matches %r{Applying.*?testspec.*?test}
      assert_match_in_file(/gem 'rack-test'.*?:require => "rack\/test".*?:group => "test"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'test-spec'.*?:require => "test\/spec"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/test/test_config.rb')
      assert_match_in_file(/Test::Unit::TestCase/, '/tmp/sample_project/test/test_config.rb')
      assert_file_exists('/tmp/sample_project/test/test.rake')
    end

    context "cucumber" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=cucumber', '--script=none') } }
      asserts_topic.matches %r{Applying.*?cucumber.*?test}
      assert_match_in_file(/gem 'rack-test'.*?:require => "rack\/test".*?:group => "test"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'rspec'.*?:require => "spec"/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'cucumber'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'capybara'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/spec/spec_helper.rb')
      assert_match_in_file(/PADRINO_ENV = 'test' unless defined\?\(PADRINO_ENV\)/, '/tmp/sample_project/features/support/env.rb')
      assert_match_in_file(/Spec::Runner/, '/tmp/sample_project/spec/spec_helper.rb')
      assert_match_in_file(/Capybara.app = /, '/tmp/sample_project/features/support/env.rb')
      assert_match_in_file(/World\(Cucumber::Web::URLs\)/, '/tmp/sample_project/features/support/url.rb')
      assert_file_exists('/tmp/sample_project/spec/spec.rake')
      assert_file_exists('/tmp/sample_project/features/support/env.rb')
      assert_file_exists('/tmp/sample_project/features/add.feature')
      assert_file_exists('/tmp/sample_project/features/step_definitions/add_steps.rb')
    end
  end

  context "stylesheet component" do

    context "sass" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--renderer=haml','--script=none','--stylesheet=sass') } }
      assert_match_in_file(/gem 'haml'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/module SassInitializer.*Sass::Plugin::Rack/m, '/tmp/sample_project/lib/sass_plugin.rb')
      assert_match_in_file(/register SassInitializer/m, '/tmp/sample_project/app/app.rb')
      assert_dir_exists('/tmp/sample_project/app/stylesheets')
    end

    context "less" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--renderer=haml','--script=none','--stylesheet=less') } }
      assert_match_in_file(/gem 'less'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/gem 'rack-less'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/module LessInitializer.*Rack::Less/m, '/tmp/sample_project/lib/less_plugin.rb')
      assert_match_in_file(/register LessInitializer/m, '/tmp/sample_project/app/app.rb')
      assert_dir_exists('/tmp/sample_project/app/stylesheets')
    end

    context "compass" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--renderer=haml','--script=none','--stylesheet=compass') } }
      assert_match_in_file(/gem 'compass'/, '/tmp/sample_project/Gemfile')
      assert_match_in_file(/Compass.configure_sass_plugin\!/, '/tmp/sample_project/lib/compass_plugin.rb')
      assert_match_in_file(/module CompassInitializer.*Sass::Plugin::Rack/m, '/tmp/sample_project/lib/compass_plugin.rb')
      assert_match_in_file(/register CompassInitializer/m, '/tmp/sample_project/app/app.rb')

      assert_file_exists('/tmp/sample_project/app/stylesheets/application.scss')
      assert_file_exists('/tmp/sample_project/app/stylesheets/partials/_base.scss')
    end
  end

end
