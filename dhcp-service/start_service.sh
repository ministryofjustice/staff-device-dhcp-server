#!/bin/bash

set -m

run_acceptance_test() {
  perfdhcp -l lo $(hostname -i) -n 20 -r 2 -D 20% -R 10 > ./test_result
}

fetch_kea_config() {
  if [[ -n $LOCAL_DEVELOPMENT ]]; then
    cp ./test_config.json /etc/kea/config.json
  else
    aws s3 cp s3://${KEA_CONFIG_BUCKET_NAME}/config.json /etc/kea/config.json
  fi
}

configure_database_credentials() {
  sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
  sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
  sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
  sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
  sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
  sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json
}

init_schema_if_not_loaded() {
  $(kea-admin db-init mysql -u ${DB_USER} -p ${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} &> /dev/null)
}

boot_server() {
  kea-dhcp4 -c /etc/kea/config.json &
}

ensure_healthy_server() {
  received_packets=`cat ./test_result |grep "received packets: 0"`

  if ! [[ -z $received_packets ]]; then
    aws sns publish --topic-arn $CRITICAL_NOTIFICATIONS_ARN --message "DHCP server failed to boot" --region eu-west-2
    exit 1
  fi
}

main() {
  fetch_kea_config
  configure_database_credentials
  init_schema_if_not_loaded
  boot_server
  run_acceptance_test
  ensure_healthy_server
  fg %1 #KEA is running as a daemon, bring it back as the essential task of the container now that testing is finished
}

main
