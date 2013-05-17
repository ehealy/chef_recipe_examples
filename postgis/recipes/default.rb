#
# Cookbook Name:: postgis
# Recipe:: default
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

# Installs necessary packages for postgis
packages = %w{postgresql-server-dev-9.2 libxml2-dev libproj-dev libjson0-dev xsltproc docbook-xsl docbook-mathml libgdal1-dev}
packages.each do |pkg|
  apt_package pkg do
    action :install
  end
end

# Manual build from source of Geos for Postgis
bash "install_geos" do
  user "root"
  cwd "/home/ubuntu"
  code <<-EOH
    wget http://download.osgeo.org/geos/geos-3.3.8.tar.bz2
    tar xvfj geos-3.3.8.tar.bz2
    cd geos-3.3.8
    ./configure
    make
    sudo make install
    cd ..
    sudo rm -rf geos-*
  EOH
end

# Manual Install of Postgis
bash "install_postgis" do
  user "root"
  cwd "/home/ubuntu"
  code <<-EOH
    wget http://download.osgeo.org/postgis/source/postgis-2.0.3.tar.gz
    tar xfvz postgis-2.0.3.tar.gz
    cd postgis-2.0.3
    ./configure
    make
    sudo make install
    sudo ldconfig
    sudo make comments-install
    sudo ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql
    sudo ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp
    sudo ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql
    cd..
    sudo rm -rf postgis-*
  EOH
end

