#
# Cookbook Name:: postgresql_weather
# Recipe:: server
#


include_recipe "postgresql_weather::client"

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end



service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

# Symlinks data to additional db drive setup in AWS image
bash "move and symlink var postgres to data db" do
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

# Symlinks /etc/postgresql files to additional db drive setup in AWS image
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

# Adds the added db drives to the fstab
bash "add db drive info to fstab" do
  user "root"
  cwd "/"
  code <<-EOH
    sudo echo "/dev/xvdf   /media/db  auto  defaults,nobootwait,noatime 0 0" >> /etc/fstab
  EOH

end


