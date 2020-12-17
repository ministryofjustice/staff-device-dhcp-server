#!/bin/bash

set -euo pipefail

printf "Waiting for database to be ready"
until docker-compose exec -T db mysql -hdb -uroot -ppassword -e 'SELECT 1' &> /dev/null
do
  printf "."
  sleep 1
done
printf "\n"