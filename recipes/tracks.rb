#
# Cookbook:: tracks
# Recipe:: tracks
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.

# Setup user for deploy
tracks 'setup_deploy_user' do
  user_name node['tracks']['app']['user']
  home_dir node['tracks']['app']['home_directory']
  packages node['tracks']['app']['packages']
  ruby_version node['tracks']['app']['ruby']
  action :setup
end

# Configure deploy user env
tracks 'configure_deploy_user' do
  user_name node['tracks']['app']['user']
  home_dir node['tracks']['app']['home_directory']
  action :configure
end

# Configure database.
include_recipe 'tracks::database'

# Get database passwords
passwords = data_bag_item('passwords', 'mysql')
# Get Rails secrets
secrets = data_bag_item('secrets', 'tracks')

# Deploy Tracks rails application
tracks 'deploy' do
  user_name node['tracks']['app']['user']
  home_dir node['tracks']['app']['home_directory']
  app_version node['tracks']['app']['version']
  repo_name node['tracks']['app']['repo']
  deploy_dir node['tracks']['app']['deploy_directory']
  db_name node['tracks']['database']['dbname']
  db_user node['tracks']['database']['username']
  db_password passwords['tracks_password']
  rais_salt secrets['salt']
  rails_secret_token secrets['secret_token']
  action :deploy
end
