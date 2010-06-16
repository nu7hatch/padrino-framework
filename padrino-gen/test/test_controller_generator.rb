require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Controller Generator" do
  $controller_path = '/tmp/sample_project/app/controllers/demo_items.rb'
  $controller_test_path = '/tmp/sample_project/test/controllers/demo_items_controller_test.rb'
  clean_up!

  context "fails outside app root" do
    setup { silence_logger { generate(:controller, 'demo', '-r=/tmp') } }
    asserts_topic.matches %r{not at the root}
    assert_no_file_exists '/tmp/app/controllers/demo.rb'
  end

  context "generate" do
    
    context "in specified app" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
        silence_logger { generate(:app, 'subby', '-r=/tmp/sample_project') }
        silence_logger { generate(:controller, 'DemoItems','-a=/subby', '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{Subby.controllers :demo_items do}, $controller_path.gsub('app','subby')
      assert_match_in_file %r{Subby.helpers do}, '/tmp/sample_project/subby/helpers/demo_items_helper.rb'
      assert_file_exists '/tmp/sample_project/subby/views/demo_items'
      assert_match_in_file %r{describe "DemoItemsController" do}, $controller_test_path.gsub('app','subby')
    end

    context "without test component" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=none') }
        silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{SampleProject.controllers :demo_items do}, $controller_path
      assert_match_in_file %r{SampleProject.helpers do}, '/tmp/sample_project/app/helpers/demo_items_helper.rb'
      assert_file_exists '/tmp/sample_project/app/views/demo_items'
      assert_no_file_exists '/tmp/sample_project/test'
    end

    context "within existing application" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
        silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{SampleProject.controllers :demo_items do}, $controller_path
      assert_match_in_file %r{SampleProject.helpers do}, '/tmp/sample_project/app/helpers/demo_items_helper.rb'
      assert_file_exists '/tmp/sample_project/app/views/demo_items'
    end

    context "controller tests with" do

      context "bacon" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
          silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{describe "DemoItemsController" do}, $controller_test_path
      end

      context "riot" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=riot') }
          silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{context "DemoItemsController" do}, $controller_test_path
      end

      context "testspec" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=testspec') }
          silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{context "DemoItemsController" do}, $controller_test_path
      end

      context "rspec" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=rspec') }
          silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{describe "DemoItemsController" do}, '/tmp/sample_project/spec/controllers/demo_items_controller_spec.rb'
      end

      context "shoulda" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=shoulda') }
          silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{class DemoItemsControllerTest < Test::Unit::TestCase}, $controller_test_path
        assert_file_exists '/tmp/sample_project/test/controllers/demo_items_controller_test.rb'
      end

      context "cucumber" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=cucumber') }
          silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{describe "DemoItemsController" do}, '/tmp/sample_project/spec/controllers/demo_items_controller_spec.rb'
        assert_match_in_file %r{Capybara.app = }, '/tmp/sample_project/features/support/env.rb'
      end
    end

    context "correct file names" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=rspec') }
        silence_logger { generate(:controller, 'DemoItems', '-r=/tmp/sample_project') }
      end
      assert_file_exists '/tmp/sample_project/app/views/demo_items'
      assert_file_exists '/tmp/sample_project/app/controllers/demo_items.rb'
      assert_file_exists '/tmp/sample_project/app/helpers/demo_items_helper.rb'
      assert_file_exists '/tmp/sample_project/spec/controllers/demo_items_controller_spec.rb'
    end

    context "route blocks" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=shoulda') }
        silence_logger { generate(:controller, 'demo_items', "get:test", "post:yada",'-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{get :test do\n  end\n}, $controller_path
      assert_match_in_file %r{post :yada do\n  end\n}, $controller_path
    end

  end


  context "destroy" do
    
    context "controller files" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') }
        silence_logger { generate(:controller, 'demo_items','-r=/tmp/sample_project') }
        silence_logger { generate(:controller, 'demo_items','-r=/tmp/sample_project','-d') }
      end
      assert_no_file_exists $controller_path
      assert_no_file_exists $controller_test_path
      assert_no_file_exists '/tmp/sample_project/app/helpers/demo_items_helper.rb'
    end

    context "rspec files" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=rspec') }
        silence_logger { generate(:controller, 'demo_items','-r=/tmp/sample_project') }
        silence_logger { generate(:controller, 'demo_items','-r=/tmp/sample_project','-d') }
      end
      assert_no_file_exists $controller_path
      assert_no_file_exists '/tmp/sample_project/app/helpers/demo_items_helper.rb'
      assert_no_file_exists '/tmp/sample_project/spec/controllers/demo_items_controller_spec.rb'
    end

  end

end
