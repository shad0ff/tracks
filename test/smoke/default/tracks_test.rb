# # encoding: utf-8

# Inspec test for recipe tracks::tracks

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('ruby1.9.3') do
  it { should be_installed }
end

describe user('tracks') do
  it { should exist }
  its('group') { should eq 'tracks' }
end

describe file('/home/tracks/.gemrc') do
  its('content') { should match(%r{gem: --user-install --env-shebang --no-rdoc --no-ri}) }
end

describe command('grep PATH /home/tracks/.bashrc') do
  its('stdout') { should eq "PATH=/home/tracks/.gem/ruby/1.9.1/bin:$PATH\n" }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end

describe file('/home/tracks/app/current') do
  it { should be_symlink }
  it { should_not be_file }
  it { should be_directory }
  its('owner') { should eq 'tracks' }
end

describe file('/home/tracks/app/current/log') do
  it { should be_symlink }
  it { should_not be_file }
  it { should be_directory }
  its('owner') { should eq 'tracks' }
end

describe file('/home/tracks/app/current/public/system') do
  it { should be_symlink }
  it { should_not be_file }
  it { should be_directory }
  its('owner') { should eq 'tracks' }
end

describe file('/home/tracks/app/current/tmp/pids') do
  it { should be_symlink }
  it { should_not be_file }
  it { should be_directory }
  its('owner') { should eq 'tracks' }
end

describe file('/home/tracks/app/current/config/database.yml') do
  it { should be_symlink }
  it { should be_file }
  it { should_not be_directory }
  its('owner') { should eq 'tracks' }
end

describe file('/home/tracks/app/current/config/site.yml') do
  it { should be_symlink }
  it { should be_file }
  it { should_not be_directory }
  its('owner') { should eq 'tracks' }
end

describe package('runit') do
  it { should be_installed }
end

describe file('/etc/service/tracks') do
  it { should be_symlink }
  it { should_not be_file }
  it { should be_directory }
  its('owner') { should eq 'root' }
end

describe file('/etc/service/tracks/run') do
  it { should be_file }
  it { should be_executable }
  its('owner') { should eq 'root' }
end

describe port 80 do
  it { should be_listening }
  its('addresses') { should include '0.0.0.0' }
end

describe port 3000 do
  sleep 10
  it { should be_listening }
  its('processes') { should include 'ruby1.9.1' }
  its('addresses') { should include '127.0.0.1' }
end

describe command 'wget -qSO- --spider localhost' do
  sleep 10
  its('stderr') { should match %r{HTTP/1\.1 200 OK} }
end
