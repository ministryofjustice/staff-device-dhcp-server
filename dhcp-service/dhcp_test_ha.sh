#!/bin/bash

echo "Deleting database leases..."
mysql --user=kea \
    --password=kea \
    --host=db \
    --database=kea \
    --execute "DELETE FROM lease4;"

# TODO pipe in ips?
while true; do
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - primary"
  perfdhcp 172.1.0.10 -n 100 -r 10 -R 100  -d3 -W3
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - standby"
  perfdhcp 172.1.0.11 -n 100 -r 10 -R 100  -d3 -W3
done
