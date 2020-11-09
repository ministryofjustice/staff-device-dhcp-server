#!/bin/bash
# -m for job control within a bash script (used to foreground server after testing)
# TODO: Add -e flag for erroring. This will cause the kea-admin command to error if the database exists.
set -m

run_acceptance_test() {
  perfdhcp -l lo $(hostname -i) -n 20 -r 2 -D 20% -R 10 > ./test_result
}

fetch_kea_config() {
  if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
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
  db_version=$(kea-admin db-version mysql -u ${DB_USER} -p ${DB_PASS} -n ${DB_NAME} -h ${DB_HOST})
  if [ -z "$db_version" ]; then
    $(kea-admin db-init mysql -u ${DB_USER} -p ${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} &> /dev/null)
  fi
}

ensure_database_permissions() {
  echo "running grants on lease db"
  mysql -u ${DB_USER} -p${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}';" #https://kea.readthedocs.io/en/kea-1.6.3/arm/admin.html
}

boot_control_agent() {
  kea-ctrl-agent -c /etc/kea/control-agent-config.json &
}

boot_server() {
  kea-dhcp4 -c /etc/kea/config.json &
}

export_server_stats() {
  while true; do curl --silent --header "Content-Type: application/json" --request POST --data '{"service":["dhcp4"],"command":"statistic-get-all"}' localhost:8000; sleep 10; done &
}

ensure_healthy_server() {
  received_packets=`cat ./test_result | grep "received packets: 0"`

  if ! [[ -z $received_packets ]]; then
    aws sns publish --topic-arn $CRITICAL_NOTIFICATIONS_ARN --message "DHCP server failed to boot" --region eu-west-2
    exit 1
  fi
}

main() {
  fetch_kea_config
  configure_database_credentials
  ensure_database_permissions
  init_schema_if_not_loaded
  boot_control_agent
  boot_server
  if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    run_acceptance_test
    ensure_healthy_server
  fi
  touch /tmp/kea_started
  export_server_stats
  fg %1 #KEA is running as a daemon, bring it back as the essential task of the container now that testing is finished
}

main
