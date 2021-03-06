#
# Cookbook Name:: postgresql_server_master
# Recipe:: client
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

if(node['postgresql']['enable_pitti_ppa'])
  include_recipe 'postgresql_server_master::ppa_pitti_postgresql'
end

if(node['postgresql']['enable_pgdg_yum'])
  include_recipe 'postgresql_server_master::yum_pgdg_postgresql'
end

node['postgresql']['client']['packages'].each do |pg_pack|

  package pg_pack

end
