#!/bin/bash

## Starts resque worker scheduler

## Exit line is commented out on master collector where scheduler is run. All other collectors will not  make use of this script

exit
. /etc/profile.d/rbenv.sh

cd /home/ubuntu/collector/current
VERBOSE=0 RAILS_ENV=production rake resque:scheduler >/home/ubuntu/scheduler.log 2>&1 &
echo $! > /home/ubuntu/scheduler.pid
