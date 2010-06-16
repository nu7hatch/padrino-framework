require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Mailer Generator" do
  clean_up!

  context "outside app root" do
    setup { silence_logger { generate(:mailer, 'demo', '-r=/tmp') } }
    asserts("output") { topic }.matches %r{not at the root}
    assert_file_exists('/tmp/app/mailers/demo_mailer.rb').not!
  end

  context "generates in specified app" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
      silence_logger { generate(:app, 'subby', '-r=/tmp/sample_project') }
      silence_logger { generate(:mailer, 'demo', '-a=/subby', '-r=/tmp/sample_project') }
    end
    assert_match_in_file(/Subby.mailer :demo/m, '/tmp/sample_project/subby/mailers/demo.rb')
    assert_dir_exists('/tmp/sample_project/subby/views/mailers/demo')
  end

  context "generates a new mailer extended from base" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
      silence_logger { generate(:mailer, 'demo', '-r=/tmp/sample_project') }
    end
    assert_match_in_file(/SampleProject.mailer :demo/m, '/tmp/sample_project/app/mailers/demo.rb')
    assert_dir_exists('/tmp/sample_project/app/views/mailers/demo')
  end

  context "generates a new mailer extended from base with long name" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
      silence_logger { generate(:mailer, 'UserNotice', '-r=/tmp/sample_project') }
    end
    assert_match_in_file(/SampleProject.mailer :user_notice/m, '/tmp/sample_project/app/mailers/user_notice.rb')
    assert_dir_exists('/tmp/sample_project/app/views/mailers/user_notice')
  end

  context "destroys generation with destroy option" do
    setup do
      silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
      silence_logger { generate(:mailer, 'demo', '-r=/tmp/sample_project') }
      silence_logger { generate(:mailer, 'demo', '-r=/tmp/sample_project','-d') }
    end
    assert_dir_exists('/tmp/sample_project/app/views/demo').not!
    assert_file_exists('/tmp/sample_project/app/mailers/demo.rb').not!
  end

end
