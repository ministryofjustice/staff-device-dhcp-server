#!/bin/bash
printf "Waiting for KEA DHCP server"

count=0
until docker-compose exec -T dhcp curl localhost &> /dev/null
do
  printf "."
  sleep 1
  let count++

  if [ $count -ge 10 ]; then
    echo "Failed to start server"
    exit 1
  fi
done
printf "\n"
