#
# Cookbook:: wordpress
# Recipe:: install
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package ['httpd', 'mysql', 'mysql-server', 'php', 'php-mysql'] do
  action :install
end

git node['wordpress']['base_dir'] do
  repository "git://#{node['wordpress']['git_repo']}"
  revision 'master'
  action :sync
end

template "#{node['wordpress']['base_dir']}/wp-config.php" do
  source 'wp-config.php.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  variables(
    :dbname => node['wordpress']['dbname'],
    :dbuser => node['wordpress']['dbuser'],
    :dbpassword => node['wordpress']['dbpassword'],
    :dbhost => node['wordpress']['dbhost'],
    :dbport => node['wordpress']['dbport']
  )
  notifies :restart, 'service[httpd]', :delayed
end

service 'mysqld' do
  action [:enable, :start]
end

bash 'set mysql root password' do
  code <<-EOH
    mysql -u root -e "create database #{node['wordpress']['dbname']};"
    mysql -u root -e "SET PASSWORD FOR #{node['wordpress']['dbuser']}@'localhost' = PASSWORD(\'#{node['wordpress']['dbpassword']}\');"
  EOH
  action :run
end

service 'httpd' do
  action [:enable, :start]
end
