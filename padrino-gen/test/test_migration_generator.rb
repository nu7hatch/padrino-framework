require File.expand_path(File.dirname(__FILE__) + '/helper')

context "Migration Generator" do
  clean_up!

  context "fail outside app root" do
    setup { silence_logger { generate(:migration, 'add_email_to_users', '-r=/tmp') } }
    asserts_topic.matches %r{not at the root}
    assert_no_file_exists '/tmp/db/migration'
  end

  context "fail if we don't use an adapter" do
    setup { silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon') } }
    asserts("raises") { silence_logger { generate(:migration, 'AddEmailToUsers', '-r=/tmp/sample_project') } }.raises SystemExit
  end

  context "generate" do

    context "migration" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
        silence_logger { generate(:migration, 'AddEmailToUsers', '-r=/tmp/sample_project') }
      end
      assert_match_in_file  %r{class AddEmailToUser}, "/tmp/sample_project/db/migrate/001_add_email_to_users.rb"
    end

    context "migration with lowercase migration argument" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
        silence_logger { generate(:migration, 'add_email_to_users', '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{class AddEmailToUsers}, "/tmp/sample_project/db/migrate/001_add_email_to_users.rb"
    end

    context "migration with singular table" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
        silence_logger { generate(:migration, 'add_email_to_user', "email:string", '-r=/tmp/sample_project') }
      end
      migration_file_path = "/tmp/sample_project/db/migrate/001_add_email_to_user.rb"
      assert_match_in_file %r{class AddEmailToUser}, migration_file_path
      assert_match_in_file %r{t.string :email}, migration_file_path
      assert_match_in_file %r{t.remove :email}, migration_file_path
    end

    context "proper version number" do
      setup do
        silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=sequel') }
        silence_logger { generate(:migration, 'add_email_to_person', "email:string", '-r=/tmp/sample_project') }
        silence_logger { generate(:migration, 'add_name_to_person', "email:string", '-r=/tmp/sample_project') }
        silence_logger { generate(:migration, 'add_age_to_user', "email:string", '-r=/tmp/sample_project') }
      end
      assert_match_in_file %r{class AddEmailToPerson}, "/tmp/sample_project/db/migrate/001_add_email_to_person.rb"
      assert_match_in_file %r{class AddNameToPerson}, "/tmp/sample_project/db/migrate/002_add_name_to_person.rb"
      assert_match_in_file %r{class AddAgeToUser}, "/tmp/sample_project/db/migrate/003_add_age_to_user.rb"
    end

    context "for activerecord migration" do

      context "generic needs" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
          silence_logger { generate(:migration, 'ModifyUserFields', '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_modify_user_fields.rb"
        assert_match_in_file %r{class ModifyUserFields}, migration_file_path
        assert_match_in_file %r{def self\.up\s+end}, migration_file_path
        assert_match_in_file %r{def self\.down\s+end}, migration_file_path
      end

      context "adding columns" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
          silence_logger { generate(:migration, 'AddEmailToUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_add_email_to_users.rb"
        assert_match_in_file %r{class AddEmailToUsers}, migration_file_path
        assert_match_in_file %r{change_table :users.*?t\.string :email}, migration_file_path
        assert_match_in_file %r{t\.integer :age}, migration_file_path
        assert_match_in_file %r{change_table :users.*?t\.remove :email}, migration_file_path
        assert_match_in_file %r{t\.remove :age}, migration_file_path
      end

      context "removing column" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=activerecord') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_remove_email_from_users.rb"
        assert_match_in_file %r{class RemoveEmailFromUsers}, migration_file_path
        assert_match_in_file %r{change_table :users.*?t\.remove :email}, migration_file_path
        assert_match_in_file %r{t\.remove :age}, migration_file_path
        assert_match_in_file %r{change_table :users.*?t\.string :email}, migration_file_path
        assert_match_in_file %r{t\.integer :age}, migration_file_path
      end

    end

    context "for datamapper migration" do

      context "generic needs" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=datamapper') }
          silence_logger { generate(:migration, 'ModifyUserFields', '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_modify_user_fields.rb"
        assert_match_in_file %r{migration\s1.*?:modify_user_fields}, migration_file_path
        assert_match_in_file %r{up\sdo\s+end}, migration_file_path
        assert_match_in_file %r{down\sdo\s+end}, migration_file_path
      end

      context "adding columns" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=datamapper') }
          silence_logger { generate(:migration, 'AddEmailToUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_add_email_to_users.rb"
        assert_match_in_file %r{migration\s1.*?:add_email_to_users}, migration_file_path
        assert_match_in_file %r{modify_table :users.*?add_column :email, DataMapper::Property::String}, migration_file_path
        assert_match_in_file %r{add_column :age, DataMapper::Property::Integer}, migration_file_path
        assert_match_in_file %r{modify_table :users.*?drop_column :email}, migration_file_path
        assert_match_in_file %r{drop_column :age}, migration_file_path
      end

      context "removing columns" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=datamapper') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_remove_email_from_users.rb"
        assert_match_in_file %r{migration\s1.*?:remove_email_from_users}, migration_file_path
        assert_match_in_file %r{modify_table :users.*?drop_column :email}, migration_file_path
        assert_match_in_file %r{drop_column :age}, migration_file_path
        assert_match_in_file %r{modify_table :users.*?add_column :email, DataMapper::Property::String}, migration_file_path
        assert_match_in_file %r{add_column :age, DataMapper::Property::Integer}, migration_file_path
      end

      context "proper version migration files" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=datamapper') }
          silence_logger { generate(:migration, 'ModifyUserFields', '-r=/tmp/sample_project') }
          silence_logger { generate(:migration, 'ModifyUserFields2', '-r=/tmp/sample_project') }
          silence_logger { generate(:migration, 'ModifyUserFields3', '-r=/tmp/sample_project') }
        end
        assert_match_in_file %r{migration\s1.*?:modify_user_fields}, "/tmp/sample_project/db/migrate/001_modify_user_fields.rb"
        assert_match_in_file %r{migration\s2.*?:modify_user_fields2}, "/tmp/sample_project/db/migrate/002_modify_user_fields2.rb"
        assert_match_in_file %r{migration\s3.*?:modify_user_fields3}, "/tmp/sample_project/db/migrate/003_modify_user_fields3.rb"

      end

    end

    context "for sequel migration" do

      context "generic needs" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=sequel') }
          silence_logger { generate(:migration, 'ModifyUserFields', '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_modify_user_fields.rb"
        assert_match_in_file %r{class ModifyUserFields}, migration_file_path
        assert_match_in_file %r{def\sup\s+end}, migration_file_path
        assert_match_in_file %r{def\sdown\s+end}, migration_file_path
      end

      context "adding columns" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=sequel') }
          silence_logger { generate(:migration, 'AddEmailToUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_add_email_to_users.rb"
        assert_match_in_file %r{class AddEmailToUsers}, migration_file_path
        assert_match_in_file %r{alter_table :users.*?add_column :email, String}, migration_file_path
        assert_match_in_file %r{add_column :age, Integer}, migration_file_path
        assert_match_in_file %r{alter_table :users.*?drop_column :email}, migration_file_path
        assert_match_in_file %r{drop_column :age}, migration_file_path
      end

      context "removing columns" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=sequel') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
        end
        migration_file_path = "/tmp/sample_project/db/migrate/001_remove_email_from_users.rb"
        assert_match_in_file %r{class RemoveEmailFromUsers}, migration_file_path
        assert_match_in_file %r{alter_table :users.*?drop_column :email}, migration_file_path
        assert_match_in_file %r{drop_column :age}, migration_file_path
        assert_match_in_file %r{alter_table :users.*?add_column :email, String}, migration_file_path
        assert_match_in_file %r{add_column :age, Integer}, migration_file_path
      end
    end

    context "destroy" do

      context "migration files" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=sequel') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', '-r=/tmp/sample_project','-d') }
        end
        assert_no_file_exists "/tmp/sample_project/db/migrate/001_remove_email_from_users.rb"
      end

      context "migration files regardless of number" do
        setup do
          silence_logger { generate(:project, 'sample_project', '--root=/tmp', '--script=none', '-t=bacon', '-d=sequel') }
          silence_logger { generate(:migration, 'AddEmailFromUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', "email:string", "age:integer", '-r=/tmp/sample_project') }
          silence_logger { generate(:migration, 'RemoveEmailFromUsers', '-r=/tmp/sample_project','-d') }
        end
        assert_no_file_exists "/tmp/sample_project/db/migrate/002_remove_email_from_users.rb"
      end

    end

  end
end
