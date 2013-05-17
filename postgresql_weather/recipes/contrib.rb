#
# Cookbook Name:: postgresql-weather
# Recipe:: contrib
#


include_recipe "postgresql_weather::server"

node['postgresql']['contrib']['packages'].each do |pg_pack|

  package pg_pack

end
