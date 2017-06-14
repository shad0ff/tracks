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

# Setup firewall
firewall 'default'

# open standard ssh port
firewall_rule 'ssh' do
  port 22
  command :allow
end

# open standard http port to tcp traffic only
firewall_rule 'http' do
  port 80
  protocol :tcp
  command :allow
end
