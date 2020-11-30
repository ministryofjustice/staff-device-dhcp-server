#!/bin/bash
printf "Waiting for KEA DHCP server"

count=0
until docker-compose exec -T dhcp ls /tmp/kea_started 2> /dev/null
do
  printf "."
  sleep 1
  let count++

  if [ $count -ge 10 ]; then
    echo "Failed to start server"
    exit 1
  fi
done
docker-compose logs
printf "\n"
