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
