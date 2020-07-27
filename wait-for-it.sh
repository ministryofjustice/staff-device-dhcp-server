#!/bin/bash

until docker-compose exec -T db mysql -hdb -uroot -ppassword -e 'SELECT 1' &> /dev/null
do
  printf "."
  sleep 1
done