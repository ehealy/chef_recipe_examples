#
# Cookbook Name:: me_collector
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




# Adds required packages for Collector app
packages = %w{ttf-liberation xvfb ghostscript libpq-dev wkhtmltopdf firefox libicu48 debhelper dpkg autotools-dev libglib2.0-dev libgtk2.0-dev libfontconfig1-dev libqt4-dev libcairo2-dev libjpeg-dev libpng-dev libtiff-dev liblcms2-dev libfreetype6-dev gtk-doc-tools pkg-config libgirepository1.0-dev gobject-introspection libglib2.0-doc}
packages.each do |pkg|
  apt_package pkg do
    action :install
  end
end

# Manual install of Poppler Utils and required packages

bash "install_poppler_utils" do
  user "root"
  cwd "/home/ubuntu"
  code <<-EOH
  wget http://poppler.freedesktop.org/poppler-0.22.1.tar.gz
  tar xzf poppler-0.22.1.tar.gz
  cd poppler-0.22.1/
  ./configure
  make
  sudo make install
  sudo ldconfig
  cd
  sudo rm -rf poppler-*
  EOH
end

# Addition of necessary shell scripts for collector and sever maintenance

cookbook_file "/home/ubuntu/start_scheduler.sh" do
  owner "ubuntu"
  source "start_scheduler.sh" 
  mode 00754
end

cookbook_file "/home/ubuntu/refresh_code.sh" do
  owner "ubuntu"
  source "refresh_code.sh" 
  mode 00754
end

cookbook_file "/home/ubuntu/logrotate.sh" do
  owner "ubuntu"
  source "logrotate.sh" 
  mode 00754
end

cookbook_file "/home/ubuntu/logrotate_mail.sh" do
  owner "ubuntu"
  source "logrotate_mail.sh"
  mode 00754
end

cookbook_file "/home/ubuntu/logrotate_config" do
  owner "ubuntu"
  source "logrotate_config" 
  mode 00754
end

cookbook_file "/home/ubuntu/logrotate_config_mail" do
  owner "ubuntu"
  source "logrotate_config_mail" 
  mode 00754
end

cookbook_file "/home/ubuntu/webdriver_cleanup.sh" do
  owner "ubuntu"
  source "webdriver_cleanup.sh" 
  mode 00754
end

cookbook_file "/home/ubuntu/detect_orphan_xvfb.rb" do
  owner "ubuntu"
  source "detect_orphan_xvfb.rb" 
  mode 00754
end




# deploys Collector
deploy "/home/ubuntu/collector" do
  ## Encryped git information
  git_creds = Chef::EncryptedDataBagItem.load("credentials", "git")
  repo git_creds['contents']
  revision "master" # or "some_specifc_version" or "TAG_for_1.0" or (subversion) "1234"
  user "ubuntu" 
  enable_submodules false # performs a submodule init and submodule update
  migrate false # allows migrations to occur during install
  migration_command "rake db:migrate" # migration command used
  environment "RAILS_ENV" => "production" # sets RAILS_ENV variable
  shallow_clone true # boolean, true sets clone depth to 5
  action :deploy # or :rollback

  # Restart sequence once collector code has completed installation
  restart_command do

      # Esnures collector is using master git branch
      rbenv_script "Switch Git Branch" do
        rbenv_version "1.9.3-p194"
        user "ubuntu" 
        cwd "/home/ubuntu/collector/current"
        code %{git checkout master}
      end

      # Installs application gems
      rbenv_script "Bundle" do
        rbenv_version "1.9.3-p194"
        user "ubuntu" 
        cwd "/home/ubuntu/collector/current"
        code %{bundle}
      end

      # Creates a doc directory
      rbenv_script "Make Doc Dir" do
        rbenv_version "1.9.3-p194"
        user "ubuntu" 
        cwd "/home/ubuntu/"
        code %{mkdir /home/ubuntu/collector/shared/doc}
      end

      # Creates a log directory
      rbenv_script "Make Log Dir" do
        rbenv_version "1.9.3-p194"
        user "ubuntu" 
        cwd "/home/ubuntu/"
        code %{mkdir /home/ubuntu/collector/shared/log}
      end

      # Adjusts the permissions on the folder just created
      rbenv_script "Change Shared Dir Permissions" do
        rbenv_version "1.9.3-p194"
        user "ubuntu" 
        cwd "/home/ubuntu/collector"
        code %{sudo chown ubuntu shared/*}
      end


      # Adds crons to cron tabs for scripts preivously added for server maintenance
      cron "Orphan Xvfb Cron" do
        user "ubuntu"
        minute 00
        command "/home/ubuntu/detect_orphan_xvfb.rb"
      end

      cron "Refresh Code Cron" do
        user "ubuntu"
        minute 00
        command "/home/ubuntu/refresh_code.sh"
      end

      cron "Logrotate Cron" do
        user "ubuntu"
        minute 00
        hour "00,06,12,18"
        command "/home/ubuntu/logrotate.sh"
      end

      cron "Logrotate Mail Cron" do
        user "ubuntu"
        minute 00
        hour 00
        day "*/2"
        command "/home/ubuntu/logrotate_mail.sh"
      end

      cron "Webdriver Cleanup Cron" do
        user "ubuntu"
        minute 00
        hour "00,06,12,18"
        command "/home/ubuntu/webdriver_cleanup.sh"
      end

    end
  # A code block to evaluate or a string containing a shell command
  #ssh_wrapper ????? # path to a wrapper script for running SSH with git. GIT_SSH environment variable is set to this.
  #git_ssh_wrapper "wrap-ssh4git.sh" # alias for ssh_wrapper
  scm_provider Chef::Provider::Git # is the default, for svn: Chef::Provider::Subversion
  # data bag variable decryption
  # data_bag_secret = Chef::EncryptedDataBagItem.load_secret("#{node[:data_bag_key][:secretpath]}")
  ###



  before_restart do

    # Writes out the contents of yml and other config folder files from encrypted data bags
    config_files = %w{awsyml databaseyml deathbycaptchayml redisyml yahooyml strongbox strongboxpub strongboxyml}

    config_files.each do |keyname|
      creds = Chef::EncryptedDataBagItem.load("credentials", keyname)
      filename = %[/home/ubuntu/collector/current/config/#{creds["filename"]}]
      puts("Removing #{filename}")
      `rm #{filename}`
      puts("Writing #{filename}")
      File.open(filename,"w") do |f| 
        f.write(creds["contents"])
      end
    end
  end
end