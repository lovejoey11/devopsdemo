#
# Cookbook:: webserver
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

# config the certificate
bash "selfsigned_certificate" do
  user "root"
  cwd node['selfsigned_certificate']['destination']
  code <<-EOH
        echo "Creating certificate ..."
        echo "Done #{node['selfsigned_certificate']['destination']}."
        EOH
end

cookbook_file "#{node['selfsigned_certificate']['destination']}.server.crt" do 
  source "certs/server.crt"
  owner "root"
  group "root"
  mode 644
end

cookbook_file "#{node['selfsigned_certificate']['destination']}.server.key" do 
  source "certs/server.key"
  owner "root"
  group "root"
  mode 644
end

cookbook_file "/etc/apache2/sites-available/default-ssl.conf" do 
  source "sites-available/default-ssl.conf"
  mode "0644"
end

cookbook_file "/etc/apache2/sites-available/000-default.conf" do
  source "sites-available/000-default.conf"
  mode "0644"

# create the certificate: make a request for signature for a certiciate, and have your own CA sign it.
bash "selfsigned_certificate" do
  user "root"
  cwd node['selfsigned_certificate']['destination']
  code <<-EOH
        echo "Creating certificate ..."
        echo "Done #{node['selfsigned_certificate']['destination']}."
        EOH
end
