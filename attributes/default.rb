#
# Cookbook:: tracks
# Attributes:: default
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.

# Requirements system applications.
default['tracks']['app']['packages'] = %w(git g++)

# Tracks deploy user.
default['tracks']['app']['user'] = 'tracks'
default['tracks']['app']['home_directory'] = '/home/tracks'
default['tracks']['app']['deploy_directory'] = 'app'

# Tracks deploy attributes.
default['tracks']['app']['ruby'] = '1.9.3'
default['tracks']['app']['repo'] = 'https://github.com/TracksApp/tracks.git'
default['tracks']['app']['version'] = 'v2.3.0'

# Tracks database attributes.
default['tracks']['database']['dbname'] = 'tracks'
default['tracks']['database']['username'] = 'tracks'
