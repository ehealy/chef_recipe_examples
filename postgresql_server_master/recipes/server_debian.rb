#
# Cookbook Name:: postgresql_server_master
# Recipe:: server_debian
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

include_recipe "postgresql_server_master::client"

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

# Moves datbase folders to new data base hd and creates necessary symlinks. 
bash "move and symlink pg data to data db" do
  user "root"
  cwd "/"
  code <<-EOH
    sudo /etc/init.d/postgresql stop
    cd /var/lib/postgresql/
    sudo mv 9.2 /media/db
    sudo ln -s /media/db/9.2 9.2
    sudo /etc/init.d/postgresql start
  EOH
end

# Moves datbase folders to new db drive and creates necessary symlinks. 
bash "move and symlink etc postgres to data db" do
  user "root"
  cwd "/"
  code <<-EOH
    sudo /etc/init.d/postgresql stop
    cd /etc/postgresql/
    sudo mv 9.2 /media/db
    sudo ln -s /media/db/9.2 9.2
    sudo /etc/init.d/postgresql start
  EOH
end

# Adds the db drive to the fstab
bash "add db drive info to fstab" do
  user "root"
  cwd "/"
  code <<-EOH
    sudo echo "/dev/xvdf   /media/db  auto  defaults,nobootwait,noatime 0 0" >> /etc/fstab
  EOH

end