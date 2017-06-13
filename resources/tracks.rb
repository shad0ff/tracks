# coding: utf-8
#
# Cookbook:: tracks
# Resource:: tracks
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.
resource_name :tracks
provides :tracks

property :user_name, String, default: 'tracks'
property :home_dir, String, default: '/home/tracks'
property :packages, Array
property :ruby_version, String, default: '1.9.3'
property :app_version, String, default: 'v2.3.0'
property :repo_name, String, default: 'https://github.com/TracksApp/tracks.git'
property :deploy_dir, String
property :db_name, String
property :db_user, String
property :db_password, String
property :rais_salt, String
property :rails_secret_token, String

action_class do
  include TracksHelper
end

action :setup do
  user_name = new_resource.user_name
  home_dir = new_resource.home_dir
  packages = new_resource.packages
  ruby_version = new_resource.ruby_version

  # Install requirements application.
  apt_package packages

  # Install application ruby by apt-get.
  apt_package "ruby#{ruby_version}"

  # Create application user.
  user user_name do
    username user_name
    home home_dir
    comment 'Tracks user'
    shell '/bin/bash'
    manage_home true
    action :create
  end
end

action :configure do
  user_name = new_resource.user_name
  home_dir = new_resource.home_dir

  # Set ~/.gemrc for tracks user.
  cookbook_file "#{home_dir}/.gemrc" do
    owner 'tracks'
    group 'tracks'
    mode '0644'
    source 'gemrc'
    action :create
  end

  # Update .bashrc with new $PATH. Add path to local gems.
  gem_path = local_gem_path(user_name,home_dir).strip
  bashrc = "#{home_dir}/.bashrc"
  ruby_block "update_#{bashrc}" do
    block do
      file = Chef::Util::FileEdit.new(bashrc)
      file.insert_line_if_no_match(gem_path, "PATH=#{gem_path}/bin:$PATH")
      file.write_file
    end
    action :run
    not_if { ::File.open(bashrc).each_line.any?{|line| line.include?(gem_path)} }
  end
end

action :deploy do
  user_name = new_resource.user_name
  home_dir = new_resource.home_dir
  app_version = new_resource.app_version
  repo_name = new_resource.repo_name
  deploy_dir = new_resource.deploy_dir
  db_name = new_resource.db_name
  db_user = new_resource.db_user
  db_password = new_resource.db_password
  rais_salt = new_resource.rais_salt
  rails_secret_token = new_resource.rails_secret_token

  gem_path = local_gem_path(user_name,home_dir).strip
  sys_envs = {
    'RAILS_ENV' => 'production',
    'PATH' => "#{gem_path}/bin:#{ENV['PATH']}",
    'USER' => user_name,
    'HOME' => home_dir
  }
  deploy_path = "#{home_dir}/#{deploy_dir}"

  deploy_revision "tracks_#{app_version}" do
    repo repo_name
    deploy_to deploy_path
    environment sys_envs
    revision app_version
    user user_name
    group user_name
    action :deploy
    migration_command 'bundle exec rake db:migrate'
    symlink_before_migrate(
      {
        'config/database.yml' => 'config/database.yml',
        'config/site.yml' => 'config/site.yml'
      }
    )
    migrate true
    before_migrate do
      current_release = release_path

      # Disable sqlite in Gemfile.
      ruby_block 'disable_sqlite' do
        block do
          file = Chef::Util::FileEdit.new("#{current_release}/Gemfile")
          file.search_file_replace_line("gem \"sqlite3\", \"~> 1.3.9\"", "# gem \"sqlite3\", \"~> 1.3.9\"")
          file.write_file
        end
        action :run
      end

      # Disable Rails's static asset server.
      ruby_block 'disable_static_asset_server' do
        block do
          file = Chef::Util::FileEdit.new("#{current_release}/config/environments/production.rb")
          file.search_file_replace_line('  config.serve_static_assets = false', '  config.serve_static_assets = true')
          file.write_file
        end
        action :run
      end

      # Install bundler.
      execute 'gem install bundler' do
        environment sys_envs
        cwd current_release
        user user_name
      end

      # Install requirement gems.
      execute "bundle install --path #{home_dir}/.gem/ --without development test" do
        environment sys_envs
        cwd current_release
        user user_name
      end

      # Create shared directories
      %w{log system pids config}.each do |dir|
        directory "#{deploy_path}/shared/#{dir}" do
          owner user_name
          group user_name
          mode '0755'
          action :create
        end
      end

      # Set database.yml
      template "#{deploy_path}/shared/config/database.yml" do
        source 'database.yml.erb'
        owner user_name
        group user_name
        mode '0644'
        variables(
          {
            db_name: db_name,
            db_user: db_user,
            db_password: db_password
          }
        )
      end

      # Set site.yml
      template "#{deploy_path}/shared/config/site.yml" do
        source "site.yml.erb"
        owner user_name
        group user_name
        mode '0644'
        variables(
          {
            salt: rais_salt,
            secret_token: rails_secret_token
          }
        )
      end
    end

    before_restart do
      current_release = release_path

      # Precompile assets.
      execute 'bundle exec rake assets:precompile' do
        environment sys_envs
        cwd current_release
        user user_name
      end
    end
  end
end

# TODO: refactor execute and ruby_block
#       use custom library functions and converge_by
