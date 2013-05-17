name              "postgresql_server_standby"
maintainer        "Ed Healy"
maintainer_email  "ehealy@gmail.com"
license           "Apache 2.0"
description       "Installs and configures postgresql standby server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1.0"
recipe            "postgresql", "Includes postgresql_server_standby::client"
recipe            "postgresql_server_standby::ruby", "Installs pg gem for Ruby bindings"
recipe            "postgresql_server_standby::client", "Installs postgresql client package(s)"
recipe            "postgresql_server_standby::server", "Installs postgresql server packages, templates"
recipe            "postgresql_server_standby::server_redhat", "Installs postgresql server packages, redhat family style"
recipe            "postgresql_server_standby::server_debian", "Installs postgresql server packages, debian family style"

%w{ubuntu debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, ">= 6.0"
end

depends "openssl"
