require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Model Generator" do
  clean_up!

  context "fail" do

    context "outside app root" do
      setup { silence_logger { generate(:model, 'user', '-r=/tmp') } }
      asserts_topic.matches %r{not at the root}
      assert_no_file_exists '/tmp/app/models/user.rb'
    end

    context "if field name is not acceptable" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=couchrest') }
        silence_logger { generate(:model, 'DemoItem', "re@l$ly:string","display-name:string", "age&year:datetime", "email_two:string", '-r=/tmp/sample_project') }
      end
      asserts_topic.matches %r{Invalid field name:}
      asserts_topic.matches %r{display-name:string}
      asserts_topic.matches %r{age&year:datetime}
      asserts_topic.matches %r{re@l\$ly:string}
      assert_no_file_exists '/tmp/sample_project/app/models/demo_item.rb'
    end

    context "without adapter" do
      setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') } }
      asserts("exception!") {silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }}.raises(SystemExit)
    end
  end

  context "generate" do

    context "filename properly" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=couchrest') }
        silence_logger { generate(:model, 'DemoItem', "name:string", "age", "email:string", '-r=/tmp/sample_project') }
      end
      assert_file_exists '/tmp/sample_project/app/models/demo_item.rb'
    end

    context "without a test component" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--test=none', '-d=activerecord') }
        silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{class User < ActiveRecord::Base}, '/tmp/sample_project/app/models/user.rb'
      assert_no_file_exists '/tmp/sample_project/test'
    end

    context "in specified app" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '-d=datamapper', '--script=none', '-t=bacon') }
        silence_logger { generate(:app, 'subby', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'Post', "body:string", '-a=/subby', '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{class Post\n\s+include DataMapper::Resource}, '/tmp/sample_project/subby/models/post.rb'
      assert_match_in_file %r{property :body, String}, '/tmp/sample_project/subby/models/post.rb'
      assert_match_in_file %r{migration 1, :create_posts do}, "/tmp/sample_project/db/migrate/001_create_posts.rb"
      assert_match_in_file %r{gem 'data_mapper'},'/tmp/sample_project/Gemfile'
    end

    context "only generates model once" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
        silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
      end
      asserts_topic.matches %r{identical\e\[0m  app/models/user.rb}
      asserts_topic.matches %r{identical\e\[0m  test/models/user_test.rb}
      assert_match_in_file %r{class User < ActiveRecord::Base}, '/tmp/sample_project/app/models/user.rb'
    end

    context "proper file versions" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
        silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'account', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'bank', '-r=/tmp/sample_project') }
      end
      assert_file_exists '/tmp/sample_project/db/migrate/001_create_users.rb'
      assert_file_exists '/tmp/sample_project/db/migrate/002_create_accounts.rb'
      assert_file_exists '/tmp/sample_project/db/migrate/003_create_banks.rb'
    end

    context "for ORM component" do
      context "activerecord" do

        context "model files" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
            silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User < ActiveRecord::Base}, '/tmp/sample_project/app/models/user.rb'
        end

        context "migration files with no fields" do
          setup do
            current_time = stop_time_for_test.strftime("%Y%m%d%H%M%S")
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
            silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
          end
          migration_file_path = "/tmp/sample_project/db/migrate/001_create_users.rb"
          assert_match_in_file %r{class CreateUsers < ActiveRecord::Migration}, migration_file_path
          assert_match_in_file %r{create_table :users}, migration_file_path
          assert_match_in_file %r{drop_table :users}, migration_file_path
        end

        context "migration files with given fields" do
          setup do
            current_time = stop_time_for_test.strftime("%Y%m%d%H%M%S")
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
            silence_logger { generate(:model, 'person', "name:string", "age:integer", "email:string", '-r=/tmp/sample_project') }
          end
          migration_file_path = "/tmp/sample_project/db/migrate/001_create_people.rb"
          assert_match_in_file %r{class CreatePeople < ActiveRecord::Migration}, migration_file_path
          assert_match_in_file %r{create_table :people}, migration_file_path
          assert_match_in_file %r{t.string :name},   migration_file_path
          assert_match_in_file %r{t.integer :age},   migration_file_path
          assert_match_in_file %r{t.string :email},  migration_file_path
          assert_match_in_file %r{drop_table :people}, migration_file_path
        end

      end

      context "couchrest" do

        context "model fileswith no properties" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=couchrest') }
            silence_logger { generate(:model, 'user', '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User < CouchRest::ExtendedDocument}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{use_database COUCHDB}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{# property <name>[\s\n]+?end}, '/tmp/sample_project/app/models/user.rb'
        end

        context "model files with given fields" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=couchrest') }
            silence_logger { generate(:model, 'person', "name:string", "age", "email:string", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class Person < CouchRest::ExtendedDocument}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{use_database COUCHDB}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{property :name}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{property :age}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{property :email}, '/tmp/sample_project/app/models/person.rb'
        end

      end

      context "datamapper" do

        context "gemfile gem" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=datamapper') }
            silence_logger { generate(:model, 'user', "name:string", "age:integer", "created_at:datetime", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{gem 'data_mapper'}, '/tmp/sample_project/Gemfile'
        end

        context "model files with fields" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=datamapper') }
            silence_logger { generate(:model, 'user', "name:string", "age:integer", "created_at:datetime", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User\n\s+include DataMapper::Resource}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{property :name, String}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{property :age, Integer}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{property :created_at, DateTime}, '/tmp/sample_project/app/models/user.rb'
        end

        context "proper version numbers" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=datamapper') }
            silence_logger { generate(:model, 'user', "name:string", "age:integer", "created_at:datetime", '-r=/tmp/sample_project') }
            silence_logger { generate(:model, 'person', "name:string", "age:integer", "created_at:datetime", '-r=/tmp/sample_project') }
            silence_logger { generate(:model, 'account', "name:string", "age:integer", "created_at:datetime", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User\n\s+include DataMapper::Resource}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{migration 1, :create_users do}, "/tmp/sample_project/db/migrate/001_create_users.rb"
          assert_match_in_file %r{class Person\n\s+include DataMapper::Resource}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{migration 2, :create_people do}, "/tmp/sample_project/db/migrate/002_create_people.rb"
          assert_match_in_file %r{class Account\n\s+include DataMapper::Resource}, '/tmp/sample_project/app/models/account.rb'
          assert_match_in_file %r{migration 3, :create_accounts do}, "/tmp/sample_project/db/migrate/003_create_accounts.rb"
        end

        context "migration with given fields" do
          setup do
            current_time = stop_time_for_test.strftime("%Y%m%d%H%M%S")
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=datamapper') }
            silence_logger { generate(:model, 'person', "name:string", "created_at:date_time", "email:string", '-r=/tmp/sample_project') }
          end
          migration_file_path = "/tmp/sample_project/db/migrate/001_create_people.rb"
          assert_match_in_file %r{class Person\n\s+include DataMapper::Resource}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{migration 1, :create_people do}, migration_file_path
          assert_match_in_file %r{create_table :people do}, migration_file_path
          assert_match_in_file %r{column :name, DataMapper::Property::String}, migration_file_path
          assert_match_in_file %r{column :created_at, DataMapper::Property::DateTime}, migration_file_path
          assert_match_in_file %r{column :email, DataMapper::Property::String}, migration_file_path
          assert_match_in_file %r{drop_table :people}, migration_file_path
        end

      end

      context "mongomapper" do

        context "model files with no properties" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=mongomapper') }
            silence_logger { generate(:model, 'person', '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class Person\n\s+include MongoMapper::Document}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{# key <name>, <type>}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{timestamps![\n\s]+end}, '/tmp/sample_project/app/models/person.rb'
        end

        context "model files with given fields" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=mongomapper') }
            silence_logger { generate(:model, 'user', "name:string", "age:integer", "email:string", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User\n\s+include MongoMapper::Document}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{key :name, String}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{key :age, Integer}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{key :email, String}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{timestamps!}, '/tmp/sample_project/app/models/user.rb'
        end
      end

      context "mongoid" do

        context "model files with no properties" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=mongoid') }
            silence_logger { generate(:model, 'person', '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class Person\n\s+include Mongoid::Document}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{# field <name>, :type => <type>, :default => <value>}, '/tmp/sample_project/app/models/person.rb'
        end

        context "model files with given fields" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=mongoid') }
            silence_logger { generate(:model, 'user', "name:string", "age:integer", "email:string", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User\n\s+include Mongoid::Document}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{field :name, :type => String}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{field :age, :type => Integer}, '/tmp/sample_project/app/models/user.rb'
          assert_match_in_file %r{field :email, :type => String}, '/tmp/sample_project/app/models/user.rb'
        end
      end

      context "sequel" do

        context "model files with given properties" do
          setup do
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=sequel') }
            silence_logger { generate(:model, 'user', "name:string", "age:integer", "created:datetime", '-r=/tmp/sample_project') }
          end
          assert_match_in_file %r{class User < Sequel::Model}, '/tmp/sample_project/app/models/user.rb'
        end

        context "migration files with given properties" do
          setup do
            current_time = stop_time_for_test.strftime("%Y%m%d%H%M%S")
            silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-d=sequel') }
            silence_logger { generate(:model, 'person', "name:string", "age:integer", "created:datetime", '-r=/tmp/sample_project') }
          end
          migration_file_path = "/tmp/sample_project/db/migrate/001_create_people.rb"
          assert_match_in_file %r{class Person < Sequel::Model}, '/tmp/sample_project/app/models/person.rb'
          assert_match_in_file %r{class CreatePeople < Sequel::Migration}, migration_file_path
          assert_match_in_file %r{create_table :people}, migration_file_path
          assert_match_in_file %r{String :name},   migration_file_path
          assert_match_in_file %r{Integer :age},   migration_file_path
          assert_match_in_file %r{DateTime :created},  migration_file_path
          assert_match_in_file %r{drop_table :people}, migration_file_path
        end
      end


    end

    context "for testing component" do

      context "bacon" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
          silence_logger { generate(:model, 'SomeUser', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{describe "SomeUser Model"}, '/tmp/sample_project/test/models/some_user_test.rb'
        assert_match_in_file %r{@some_user = SomeUser.new}, '/tmp/sample_project/test/models/some_user_test.rb'
        assert_match_in_file %r{@some_user\.should\.not\.be\.nil}, '/tmp/sample_project/test/models/some_user_test.rb'
      end

      context "riot" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=riot', '-d=activerecord') }
          silence_logger { generate(:model, 'SomeUser', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{context "SomeUser Model" do}, '/tmp/sample_project/test/models/some_user_test.rb'
        assert_match_in_file %r{SomeUser.new}, '/tmp/sample_project/test/models/some_user_test.rb'
        assert_match_in_file %r{asserts\("that record is not nil"\) \{ \!topic.nil\? \}}, '/tmp/sample_project/test/models/some_user_test.rb'
      end

      context "rspec" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=rspec', '-d=activerecord') }
          silence_logger { generate(:model, 'SomeUser', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{describe "SomeUser Model"}, '/tmp/sample_project/spec/models/some_user_spec.rb'
        assert_match_in_file %r{@some_user = SomeUser.new}, '/tmp/sample_project/spec/models/some_user_spec.rb'
        assert_match_in_file %r{@some_user\.should_not be_nil}, '/tmp/sample_project/spec/models/some_user_spec.rb'
      end

      context "shoulda" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=shoulda', '-d=activerecord') }
          silence_logger { generate(:model, 'SomePerson', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{class SomePersonControllerTest < Test::Unit::TestCase}, '/tmp/sample_project/test/models/some_person_test.rb'
        assert_match_in_file %r{context "SomePerson Model"}, '/tmp/sample_project/test/models/some_person_test.rb'
        assert_match_in_file %r{@some_person = SomePerson.new}, '/tmp/sample_project/test/models/some_person_test.rb'
        assert_match_in_file %r{assert_not_nil @some_person}, '/tmp/sample_project/test/models/some_person_test.rb'
      end

      context "testspec" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=testspec', '-d=activerecord') }
          silence_logger { generate(:model, 'SomeUser', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{context "SomeUser Model"}, '/tmp/sample_project/test/models/some_user_test.rb'
        assert_match_in_file %r{@some_user = SomeUser.new}, '/tmp/sample_project/test/models/some_user_test.rb'
        assert_match_in_file %r{@some_user\.should\.not\.be\.nil}, '/tmp/sample_project/test/models/some_user_test.rb'
      end
    end


  end

  context "destroy" do

    context "model files" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
        silence_logger { generate(:model, 'User', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'User', '-r=/tmp/sample_project', '-d') }
      end
      assert_no_file_exists '/tmp/sample_project/app/models/user.rb'
      assert_no_file_exists '/tmp/sample_project/test/models/user_test.rb'
      assert_no_file_exists '/tmp/sample_project/db/migrate/001_create_users.rb'
    end

    context "spec files" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=rspec', '-d=activerecord') }
        silence_logger { generate(:model, 'User', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'User', '-r=/tmp/sample_project', '-d') }
      end
      assert_no_file_exists '/tmp/sample_project/spec/models/user_spec.rb'
    end

    context "migration files" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=rspec', '-d=activerecord') }
        silence_logger { generate(:model, 'Person', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'User', '-r=/tmp/sample_project') }
        silence_logger { generate(:model, 'User', '-r=/tmp/sample_project', '-d') }
      end
      assert_no_file_exists '/tmp/sample_project/db/migrate/002_create_users.rb'
    end
  end

end
