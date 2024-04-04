#!/bin/bash

set -euo pipefail

printf "Waiting for Primary KEA DHCP server"

count=0
sleep 30
until docker-compose exec -T dhcp-primary ls /tmp/kea_started 2> /dev/null
do
  printf "."
  sleep 1
  (( count++ )) || true

  if [ "$count" -ge 10 ]; then
    echo "Failed to start server"
    docker-compose logs
    exit 1
  fi
done
printf "\n"
