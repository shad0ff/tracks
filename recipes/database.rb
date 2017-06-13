#
# Cookbook:: tracks
# Recipe:: database
#
# Copyright:: 2017, Yurii Pyvovarov, All Rights Reserved.

# Load MySQL passwords from the 'passwords' data bag.
passwords = data_bag_item('passwords', 'mysql')

# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

# Configure the MySQL service.
mysql_service 'default' do
  initial_root_password passwords['root_password']
  action [:create, :start]
end

# Install the mysql2 Ruby gem.
mysql2_chef_gem 'default' do
  action :install
end

mysql_connection_info = {
  host: '127.0.0.1',
  username: 'root',
  password: passwords['root_password']
}

# Create the database instance.
mysql_database node['tracks']['database']['dbname'] do
  connection mysql_connection_info
  action :create
end

# Add a database user.
mysql_database_user node['tracks']['database']['username'] do
  connection mysql_connection_info
  password passwords['tracks_password']
  database_name node['tracks']['database']['dbname']
  host '127.0.0.1'
  action [:create, :grant]
end
