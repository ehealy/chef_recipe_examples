#! /bin/bash
#
# Custom log roatation script to rotate collector log files
#

cd /home/ubuntu
logrotate -f /home/ubuntu/logrotate_config -s /home/ubuntu/logrotate_status
pkill -QUIT -f resq
sleep 5
./start_scheduler.sh


