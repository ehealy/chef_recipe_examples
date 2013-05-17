#! /bin/bash
#
# A shell script that refreshed collector code when updates are available
#

cd /home/ubuntu/collector/current
git pull | grep "Already up-to-date" >/dev/null 2>&1
if [ $? -ne 0 ]
        then
        git pull
        bundle
        pkill -QUIT -f resq
        sleep 5
        cd ~
        ./start_scheduler.sh
else
        echo "codebase does not need to be updated."
fi
