#!/bin/bash
printf "Waiting for database to be ready"
until docker-compose exec -T db mysql -hdb -uroot -ppassword -e 'SELECT 1' &> /dev/null
do
  echo $(docker-compose exec -T db mysql -hdb -uroot -ppassword -e 'SELECT 1')
  printf "."
  sleep 1
done
printf "\n"