#
# Cookbook:: tracks
# Recipe:: default
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.

# Update apt cache.
apt_update 'daily' do
  frequency 86_400
  action :periodic
end

# Install Tracks app.
include_recipe 'tracks::tracks'
