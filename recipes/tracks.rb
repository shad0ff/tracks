#
# Cookbook:: tracks
# Recipe:: tracks
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.

# Configure database.
include_recipe 'tracks::database'

# Configure Nginx web server.
include_recipe 'chef_nginx'
# Set Nginx Tracks config.
nginx_site 'tracks' do
  action :enable
  template 'tracks.conf.erb'
  variables(
    {
      deploy_path: "#{node['tracks']['app']['home_directory']}/#{node['tracks']['app']['deploy_directory']}"
    }
  )
end

# Setup user for deploy.
tracks 'setup_deploy_user' do
  user_name node['tracks']['app']['user']
  home_dir node['tracks']['app']['home_directory']
  packages node['tracks']['app']['packages']
  ruby_version node['tracks']['app']['ruby']
  action :setup
end

# Configure deploy user env.
tracks 'configure_deploy_user' do
  user_name node['tracks']['app']['user']
  home_dir node['tracks']['app']['home_directory']
  action :configure
end

# Setup runit to auto start Tracks.
runit 'demonize_tracks' do
  user_name node['tracks']['app']['user']
  home_dir node['tracks']['app']['home_directory']
  deploy_dir node['tracks']['app']['deploy_directory']
  action :setup
end

# Get database passwords
passwords = data_bag_item('passwords', 'mysql')
# Get Rails secrets.
secrets = data_bag_item('secrets', 'tracks')

# Deploy Tracks rails application.
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
  notifies :enable, 'runit[demonize_tracks]', :immediate
end
