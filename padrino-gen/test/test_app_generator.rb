require File.expand_path(File.dirname(__FILE__) + '/helper')

context "App Generator" do
  clean_up!

  context "outside app root" do
    setup { silence_logger { generate(:app, 'demo', '-r=/tmp') } }
    asserts_topic.matches %r{not at the root}
    assert_no_dir_exists('/tmp/demo')
  end

  context "create a new padrino application" do    
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp') }
      silence_logger { generate(:app, 'demo', '--root=/tmp/sample_project') }
    end
    assert_file_exists('/tmp/sample_project')
    assert_file_exists('/tmp/sample_project/demo')
    assert_file_exists('/tmp/sample_project/demo/app.rb')
    assert_file_exists('/tmp/sample_project/demo/controllers')
    assert_file_exists('/tmp/sample_project/demo/helpers')
    assert_file_exists('/tmp/sample_project/demo/views')
    assert_file_exists('/tmp/sample_project/demo/views/layouts')
    assert_match_in_file('Padrino.mount("Demo").to("/demo")', '/tmp/sample_project/config/apps.rb')
    assert_match_in_file('class Demo < Padrino::Application', '/tmp/sample_project/demo/app.rb')
  end

  context "generate tiny app skeleton" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp') }
      silence_logger { generate(:app,'demo','--tiny','--root=/tmp/sample_project') }
    end

    assert_file_exists('/tmp/sample_project')
    assert_file_exists('/tmp/sample_project/demo')
    assert_file_exists('/tmp/sample_project/demo/helpers.rb')
    assert_file_exists('/tmp/sample_project/demo/controllers.rb')
    assert_file_exists('/tmp/sample_project/demo/mailers.rb')
    assert_dir_exists('/tmp/sample_project/demo/views/mailers')
    assert_match_in_file(/:notifier/,'/tmp/sample_project/demo/mailers.rb')
    assert_no_file_exists('/tmp/sample_project/demo/helpers')
    assert_no_file_exists('/tmp/sample_project/demo/controllers')
  end

  context "create a new controller inside app" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp') }
      silence_logger { generate(:app, 'demo', '--root=/tmp/sample_project') }
      silence_logger { generate(:controller, 'demo_items', '-r=/tmp/sample_project', '-a=demo') }
    end
    assert_match_in_file(/Demo.controllers :demo_items do/m, '/tmp/sample_project/demo/controllers/demo_items.rb')
    assert_match_in_file(/Demo.helpers do/m, '/tmp/sample_project/demo/helpers/demo_items_helper.rb')
    assert_file_exists('/tmp/sample_project/demo/views/demo_items')
  end

  context "correctly create a new mailer inside a padrino application" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
      silence_logger { generate(:app, 'demo', '--root=/tmp/sample_project') }
      silence_logger { generate(:mailer, 'notify', '-r=/tmp/sample_project', '-a=demo') }
    end
    assert_match_in_file(/Demo.mailer :notify/m, '/tmp/sample_project/demo/mailers/notify.rb')
    assert_dir_exists('/tmp/sample_project/demo/views/mailers/notify')
  end

end