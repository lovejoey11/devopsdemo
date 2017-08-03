#
# Cookbook:: alb
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
apt_update 'Update the apt cache daily' do
  frequency 86_400
  action :periodic
end

package 'apache2' do
  action :install
end

service 'apache2' do
  action [ :enable, :start ]
end

cookbook_file "/var/www/html/index.html" do
  source "index.html"
  mode "0644"
end

# create output dir
directory node['selfsigned_certificate']['destination'] do
    owner "root"
    group "root"
    mode 0755
    action :create
    recursive true
end

remote_directory node['selfsigned_certificate']['destination'] do
  source 'certs'
  files_owner 'root'
  files_group 'root'
  files_mode 00644
  owner 'root'
  group 'root'
  mode 0755
end

cert = ssl_certificate 'default-ssl' do
  namespace node['default-ssl']
  notifies :restart, 'service[apache2]'
end

include_recipe 'apache2'
#include_recipe 'apache2::mod_ssl'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_deflate'
include_recipe 'apache2::mod_headers'

apache_module "ssl"  do
 #   cookbook 'apache2' 
    conf true
end

#apache_module "header"  do
#    cookbook 'apache2'  
#    conf true
#    end

web_app 'default-ssl' do
  cookbook 'apache2'
  cookbook 'ssl_certificate'
  server_name node['serverip'] 
  docroot '/var/www/html'
  ssl_key node['ssl_key']['source']
  ssl_cert node['ssl_cert']['source']
  enable 'default-ssl'
  application_name 'default-ssl'
end

service 'apache2' do
  action [ :restart ]
end

#template '/etc/apache2/sites-available/default-ssl.conf' do 
#  source 'sslconfig.erb'
#  mode 0644
#  owner 'root'
#  group 'root'
#  variables({
#  sslip:  '35.167.219.75',
#  sslcrt:  node['ssl_cert']['source'],
#  sslkey:  node['ssl_key']['source']
#  })
#end
#file '/etc/apache2/sites-available/000-default.conf' do 
#  mode 0644
#  owner 'root'
#  group 'root'
#  content <<-CFG
#    <VirtualHost *:80>
#    Redirect "/" "https://35.167.219.75/"
#    </VirtualHost>
#CFG
#end

#bash 'enable_ssl' do 
#  user 'root'
#  code <<-EOH
#        echo 'enabling necessary configurations ... '
#        a2enmod ssl
#        a2enmod headers
#        a2ensite default-ssl
#        EOH
#end

#service 'apache2' do
#  action [ :restart ]
#end
