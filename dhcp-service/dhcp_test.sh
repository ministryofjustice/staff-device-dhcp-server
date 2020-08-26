#!/bin/bash
set -e
# echo "Sleeping to wait for kea..."
# sleep 1

echo "Deleting database leases..."
mysql --user=kea \
    --password=kea \
    --host=db \
    --database=kea \
    --execute "DELETE FROM lease4;"

echo "Running perfdhcp..."
# -r rate
# -n num-requests
# -R num-clients
# -d drop-time
# -W exit-wait-time
number_of_clients=10
perfdhcp -r 10 \
         -n $number_of_clients \
         -R $number_of_clients \
         -d 2 \
         -W 10000 \
         172.1.0.3 > /dev/null 2>&1 # Will exit if too many packets dropped

echo "Checking leases created..."
count=$(mysql --user=kea --password=kea --host=db --database=kea --silent --silent --skip-column-names --execute "SELECT count(*) FROM lease4;")

if (( $count == $number_of_clients )); then 
    echo "Succeeded creating $count leases"
    exit 0
elif (( $count > 0 )); then
    echo "Failed to create $number_of_clients leases, only managed $count."
    exit 1
else
    echo "Failed to create any leases. Is the server running?"
    exit 1
fi
