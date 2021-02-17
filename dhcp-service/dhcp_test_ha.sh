#!/bin/bash

echo "Deleting database leases..."
mysql --user=kea \
    --password=kea \
    --host=db \
    --database=kea \
    --execute "DELETE FROM lease4;"

while true; do
  echo -e "--------------------------------------"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - primary"
  perfdhcp 172.1.0.10 -n 10 -r 5 -R 10  -d 1 -W 10000000

  echo -e "**************************************"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - standby"
  perfdhcp 172.1.0.11 -n 10 -r 5 -R 10  -d 1 -W 10000000
done
