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
include_recipe 'apache2::mod_ssl'
web_app 'default-ssl' do
  cookbook 'ssl_certificate'
  server_name node['ssl_host']['ip'] 
  docroot '/var/www/html'
  ssl_key node['ssl_key']['source']
  ssl_cert node['ssl_cert']['source']
end
template '/etc/apache2/sites-available/default-ssl.conf' do 
  source 'sslconfig.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables({
  sslip:  node['ssl_host']['ip'],
  sslcrt:  node['ssl_cert']['source'],
  sslkey:  node['ssl_key']['source']
  })
end
file '/etc/apache2/sites-available/000-default.conf' do 
  mode 0644
  owner 'root'
  group 'root'
  content <<-CFG
<VirtualHost *:80>
  # The ServerName directive sets the request scheme, hostname and port that
  # the server uses to identify itself. This is used when creating
  # redirection URLs. In the context of virtual hosts, the ServerName
  # specifies what hostname must appear in the request's Host: header to
  # match this virtual host. For the default virtual host (this file) this
  # value is not decisive as it is used as a last resort host regardless.
  # However, you must set it for any further virtual host explicitly.
  #ServerName www.example.com

  ServerAdmin webmaster@localhost
  DocumentRoot /var/www/html
  Redirect permanent "/" "https://#{node['ssl_host']['ip']}/"
  # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
  # error, crit, alert, emerg.
  # It is also possible to configure the loglevel for particular
  # modules, e.g.
  #LogLevel info ssl:warn

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  # For most configuration files from conf-available/, which are
  # enabled or disabled at a global level, it is possible to
  # include a line for only one particular virtual host. For example the
  # following line enables the CGI configuration for this host only
  # after it has been globally disabled with "a2disconf".
  #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
CFG
end

bash 'enable_ssl' do 
  user 'root'
  code <<-EOH
        echo 'enabling necessary configurations ... '
        a2enmod ssl
        a2enmod headers
        a2enmod rewrite
        a2ensite 000-default
        a2ensite default-ssl
        EOH
end

service 'apache2' do
  action [ :restart ]
end
