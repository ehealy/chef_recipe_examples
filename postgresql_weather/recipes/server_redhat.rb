#
# Cookbook Name:: postgresql_weather
# Recipe:: server
#


include_recipe "postgresql_server_standby::client"

# Create a group and user like the package will.
# Otherwise the templates fail.

group "postgres" do
  gid 26
end

user "postgres" do
  shell "/bin/bash"
  comment "PostgreSQL Server"
  home "/var/lib/pgsql"
  gid "postgres"
  system true
  uid 26
  supports :manage_home => false
end

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

execute "/sbin/service #{node['postgresql']['server']['service_name']} initdb" do
  not_if { ::FileTest.exist?(File.join(node['postgresql']['dir'], "PG_VERSION")) }
end

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
