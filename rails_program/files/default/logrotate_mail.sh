#! /bin/bash
#
# Custom log roatation script to rotate mail log files
#

cd /home/ubuntu
logrotate -f /home/ubuntu/logrotate_config_mail -s /home/ubuntu/logrotate_status_mail


