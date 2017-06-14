# coding: utf-8
#
# Cookbook:: tracks
# Resource:: runit
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.
resource_name :runit
provides :runit

property :user_name, String, default: 'tracks'
property :home_dir, String, default: '/home/tracks'
property :deploy_dir, String

action_class do
  include TracksHelper
end

action :setup do
  user_name = new_resource.user_name
  home_dir = new_resource.home_dir
  deploy_dir = new_resource.deploy_dir

  # Install runit package
  apt_package 'runit'

  # Update .bashrc with new $PATH. Add path to local gems.
  gem_path = local_gem_path(user_name,home_dir).strip
  deploy_path = "#{home_dir}/#{deploy_dir}"

  # Create tracks runit service
  directory "/etc/sv/#{user_name}/log" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  template "/etc/sv/#{user_name}/run" do
    source 'run.erb'
    owner 'root'
    group 'root'
    mode '0700'
    variables(
      {
        gem_path: gem_path,
        user: user_name,
        deploy_path: deploy_path
      }
    )
  end

  template "/etc/sv/#{user_name}/log/run" do
    source 'log_run.erb'
    owner 'root'
    group 'root'
    mode '0700'
    variables(
      {
        deploy_path: deploy_path
      }
    )
  end

  link "/etc/service/#{user_name}" do
    to "/etc/sv/#{user_name}"
  end

end
