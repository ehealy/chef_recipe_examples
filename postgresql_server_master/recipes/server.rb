#
# Cookbook Name:: postgresql_server_master
# Recipe:: server
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Added to clean up any previous PSQL instances that may be running
`sudo service postgresql stop`
`sudo rm /var/run/postgresql`


::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "postgresql_server_master::client"

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select do |attr|
    node['postgresql']['password'][attr].nil?
  end.map { |attr| "node['postgresql']['password']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note"
      ].join(' '))
  end
else
  node.set_unless['postgresql']['password']['postgres'] = secure_password
  node.save
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when "rhel", "fedora", "suse"
  include_recipe "postgresql_server_master::server_redhat"
when "debian"
  include_recipe "postgresql_server_master::server_debian"
end

# Adding snakeoil key and cert if ssl is activated on the server
if (node['postgresql']['config']['ssl'] == true)
  # Writes out the contents of yml and other config folder files from encrypted data bags
  config_files = %w{ssl-cert-snakeoilpem ssl-cert-snakeoilkey}

  config_files.each do |keyname|
    creds = Chef::EncryptedDataBagItem.load("database", keyname)
    
    if (keyname == 'ssl-cert-snakeoilpem')
      filename = %[/etc/ssl/certs/#{creds["filename"]}]
    else
      filename = %[/etc/ssl/private/#{creds["filename"]}]
    end
    
    puts("Removing #{filename}")
    `sudo rm #{filename}`
    puts("Writing #{filename}")
    File.open(filename,"w") do |f| 
      f.write(creds["contents"])
    end
    
    # Changing the permissions of the key and cert
    if (filename == %[/etc/ssl/private/#{creds["filename"]}])
    puts "Changing Pemissions of #{filename}"
    `sudo chmod 640 #{filename}`
    `sudo chown root:ssl-cert #{filename}`
    else
    puts "Changing Pemissions of #{filename}"
    `sudo chmod 644 #{filename}`
    end

  end

end

# Adding a wal archive folder
bash "Create wal archive folder" do
  user 'postgres'
  code <<-EOH
mkdir /etc/postgresql/#{node['postgresql']['version']}/wal_archive
  EOH
action :run
end

# Changing the shared memory settings for the server
bash "Change shmmax and shmall values" do
  user "root"
  cwd "/etc/ssl/private"
  code <<-EOH
sudo sysctl -w kernel.shmmax=2415919104
sudo sysctl -w kernel.shmall=589824
  EOH
end

# Adding SHMMAX and SHMMIN vlaues to postgres sysctl config file
template "/etc/sysctl.d/30-postgresql-shm.conf" do
  owner "root"
  source "30-postgresql-shm.conf" 
  mode 00644
end

# Adds the postgresql.conf file
template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, 'service[postgresql]', :immediately
end

# Adds the pg_hba.conf file
template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies :reload, 'service[postgresql]', :immediately
end

# Adds rsync_slave_databases.sh script
cookbook_file "#{node['postgresql']['dir']}/rsync_slave_databases.sh" do
  owner "postgres"
  source "rsync_slave_databases.sh" 
  mode 00754
end

# Adds new standby node setup script
cookbook_file "/home/ubuntu" do
  owner "ubuntu"
  source "add_new_standby_db.sh" 
  mode 00754
end


# Default PostgreSQL install has 'ident' checking on unix user 'postgres'
# and 'md5' password checking with connections from 'localhost'. This script
# runs as user 'postgres', so we can execute the 'role' and 'database' resources
# as 'root' later on, passing the below credentials in the PG client.
bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql
  EOH
  not_if "echo '\\connect' | PGPASSWORD=#{node['postgresql']['password']['postgres']} psql --username=postgres --no-password -h localhost"
  action :run
end
