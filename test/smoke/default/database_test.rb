# # encoding: utf-8

# Inspec test for recipe tracks::database

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe mysql_conf('/etc/mysql-default/my.cnf').params('mysqld') do
  its('port') { should eq '3306' }
  its('socket') { should eq '/run/mysql-default/mysqld.sock' }
end

describe port 3306 do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end

describe command("mysql -h 127.0.0.1 -utracks -pri2eip6koo9U -D tracks -e 'describe schema_migrations;'") do
  its('stdout') { should match(/version/) }
end
