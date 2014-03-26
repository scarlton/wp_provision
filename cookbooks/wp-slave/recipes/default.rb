#
# Cookbook Name:: wp-slave
# Recipe:: default
#
# Copyright 2014, Rockstar Digital
#
# All rights reserved - Do Not Redistribute
#


# create content directory
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

# enable vhost
apache_site "#{node[:server_name]}.conf" do
  enable true
end
