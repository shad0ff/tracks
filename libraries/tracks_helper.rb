# coding: utf-8
#
# Cookbook:: tracks
# Library:: tracks_helper
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.

module TracksHelper
  def local_gem_path(user, home)
    cmd = Mixlib::ShellOut.new("ruby -rubygems -e 'puts Gem.user_dir'", :user => user, :env => {'HOME' => home})
    return cmd.run_command.stdout
  end
end
