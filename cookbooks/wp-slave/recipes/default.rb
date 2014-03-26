#
# Cookbook Name:: wp-slave
# Recipe:: default
#
# Copyright 2014, Rockstar Digital
#
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)


# generate random values
node.set['wordpress']['db']['password'] = secure_password
node.set['wordpress']['keys']['auth'] = secure_password
node.set['wordpress']['keys']['secure_auth'] = secure_password
node.set['wordpress']['keys']['logged_in'] = secure_password
node.set['wordpress']['keys']['nonce'] = secure_password

# create content directories
%w{conf http_docs}.each do |dir|
  directory "/var/www/vhosts/#{node[:server_name]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
  end
end

# create log files
%w{access error}.each do |logtype|
  file "/var/log/apache2/#{node[:server_name]}-#{logtype}.log" do
    owner "root"
    group "root"
    mode "0664"
    action :create
  end
end

# create apache vhost config
template "/etc/apache2/sites-available/#{node[:server_name]}.conf" do
  source "apache.conf.erb"
  action :create
  variables(
    :server_name => node[:server_name]
  )
end

# download wordpress package
remote_file "#{Chef::Config[:file_cache_path]}/wordpress-#{node['wordpress']['version']}.tar.gz" do
  checksum node['wordpress']['checksum']
  source "http://wordpress.org/wordpress-#{node['wordpress']['version']}.tar.gz"
  mode "0644"
end

# un-tar wordpress files
execute "untar-wordpress" do
  cwd "/var/www/vhosts/#{node[:server_name]}/http_docs"
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/wordpress-#{node['wordpress']['version']}.tar.gz"
  creates "/var/www/vhosts/#{node[:server_name]}/http_docs/wp-settings.php"
end

# write wordpress configuration
template "/var/www/vhosts/#{node[:server_name]}/http_docs/wp-config.php" do
  source "wp-config.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :database        => node['wordpress']['db']['database'],
    :user            => node['wordpress']['db']['user'],
    :password        => node['wordpress']['db']['password'],
    :auth_key        => node['wordpress']['keys']['auth'],
    :secure_auth_key => node['wordpress']['keys']['secure_auth'],
    :logged_in_key   => node['wordpress']['keys']['logged_in'],
    :nonce_key       => node['wordpress']['keys']['nonce']
  )
end

# enable vhost
apache_site "#{node[:server_name]}.conf" do
  enable true
end
