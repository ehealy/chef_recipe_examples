#! /bin/bash
#
# Custom webdiver cleanup script that removes files that are older than two hours old. 
#

find /tmp/webdriver-* -mmin +120 -exec rm {} \;
