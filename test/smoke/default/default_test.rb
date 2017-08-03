# # encoding: utf-8

# Inspec test for recipe webserver::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

describe package('apache2') do
  it { should be_installed }
end

# This is an example test, replace it with your own test.
describe port(443) do
  it { should be_listening }
end

describe port(80) do
  it { should be_listening }
end

describe command('systemctl status apache2') do
  its('exit_status') { should eq 0 }
end

describe file('/usr/var/ssl/certs/server.crt') do
    it { should exist }
  end
describe file('/usr/var/ssl/certs/server.key') do
    it { should exist }
end

