#! /bin/bash

sudo cp -rf /etc/postgresql/9.2/main/conf_backups/*.conf /etc/postgresql/9.2/main
sudo /etc/init.d/postgresql start
