#! /bin/bash

me=”$0”
new_ip=$1
new_nodename=$2

if [ $# -lt 2 ]; then
  echo "$me: Must provide an ip and nodename"
  exit 3
fi

ssh postgres@$new_ip ls

if [ $? -ne 0 ]; then
  echo "$me: Do not have ssh access to postgres@$new_ip"
  exit 4
fi

sudo bash <<EOF
echo "$new_ip $new_nodename" >>/etc/hosts
echo "postgres@$new_nodename" >> /home/ubuntu/list_of_slaves
echo "host      replication     replicator      $new_ip/32      trust" >> /etc/postgresql/9.2/main/pg_hba.conf
su postgres -c "psql -c \"SELECT pg_start_backup('backup');\" "
su postgres -c "scp -r /var/lib/postgresql/9.2/main/* postgres@$new_nodename:/media/db/9.2/main"
su postgres -c "psql -c \"SELECT pg_stop_backup();\" "
EOF

sudo /etc/init.d/postgresql refresh
ssh postgres@$new_nodename ./finish_standby_setup.sh
