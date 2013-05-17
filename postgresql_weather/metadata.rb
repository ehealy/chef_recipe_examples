name              "postgresql_weather"
maintainer        "Ed Healy"
maintainer_email  "ehealy@gmail.com"
license           "Apache 2.0"
description       "Installs and configures postgresql server for an application specific weather database"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "2.2.4"
recipe            "postgresql_weather", "Includes postgresql::client"
recipe            "postgresql_weather::ruby", "Installs pg gem for Ruby bindings"
recipe            "postgresql_weather::client", "Installs postgresql client package(s)"
recipe            "postgresql_weather::server", "Installs postgresql server packages, templates"
recipe            "postgresql_weather::server_redhat", "Installs postgresql server packages, redhat family style"
recipe            "postgresql_weather::server_debian", "Installs postgresql server packages, debian family style"

%w{ubuntu debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, ">= 6.0"
end

depends "openssl"
