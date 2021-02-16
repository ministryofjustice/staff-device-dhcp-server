#!/bin/bash

set -euo pipefail
SERVER='dhcp-primary'

if [ $# -ge 1 ] && [ -n "$1" ]; then
  SERVER=$1
fi

printf "Waiting for $SERVER KEA DHCP server"

count=0
until docker-compose exec -T $SERVER ls /tmp/kea_started 2> /dev/null
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
