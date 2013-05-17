#! /bin/bash

#path=$1
#file=$2
#slaves="postgres@db1 postgres@medb3"

#for slave in $slaves; do
#       echo rsync -avz -e ssh $path $slave:/var/lib/postgresql/9.2/wal_archive/$file
#done

path=$1
file=$2
slaves=$(</home/ubuntu/list_of_slaves)
for slave in $slaves; do
        echo "echo rsync -avz -e ssh $path $slave:/var/lib/postgresql/9.2/wal_archive/$file"
done
