#!/bin/bash

# Scipt used by monit to start application processes

. /etc/profile.d/rbenv.sh

export PATH=$PATH:/usr/local/bin

cd /home/ubuntu/application/current
VERBOSE=0 RAILS_ENV=production QUEUE=status,priority,calculate,extract,retrieve,store,scrape rake resque:work >/home/ubuntu/application_process_$1.log 2>&1 &
echo $! > /home/ubuntu/resque_$1.pid
