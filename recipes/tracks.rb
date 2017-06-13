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
