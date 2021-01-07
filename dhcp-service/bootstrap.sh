#!/bin/bash
# -m for job control within a bash script (used to foreground server after testing)
# TODO: Add -e flag for erroring. This will cause the kea-admin command to error if the database exists.
set -m

fetch_kea_config() {
  if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    cp ./test_config.json /etc/kea/config.json
  else
    aws s3 cp s3://${KEA_CONFIG_BUCKET_NAME}/config.json /tmp/configurations/config.json
    cp /tmp/configurations/config.json /etc/kea/config.json
  fi
}

configure_database_credentials() {
  sed -i "s/<INTERFACE>/$INTERFACE/g" $1
  sed -i "s/<DB_NAME>/$DB_NAME/g" $1
  sed -i "s/<DB_USER>/$DB_USER/g" $1
  sed -i "s/<DB_PASS>/$DB_PASS/g" $1
  sed -i "s/<DB_HOST>/$DB_HOST/g" $1
  sed -i "s/<DB_PORT>/$DB_PORT/g" $1
  sed -i "s/<SERVER_NAME>/$SERVER_NAME/g" $1
  sed -i "s/<PRIMARY_IP>/$PRIMARY_IP/g" $1
  sed -i "s/<STANDBY_IP>/$STANDBY_IP/g" $1
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
  echo "Booting control agent"
  kea-ctrl-agent -c /etc/kea/control-agent-config.json &
}

boot_server() {
  echo "Booting dhcpv4 server"
  kea-dhcp4 -c /etc/kea/config.json &
}

boot_metrics_agent() {
  echo "Booting metrics agent"
  ruby ./metrics/boot_metrics_agent.rb &
}

start_kea_config_reload_daemon(){
  echo "Booting config reload agent"
  if [ "$LOCAL_DEVELOPMENT" != "true" ]; then
    while [ true ]; do
      echo "Checking for new configurations..."
      aws s3 sync s3://${KEA_CONFIG_BUCKET_NAME} /tmp/configurations --exclude "*" --include "config.json"
      configure_database_credentials /tmp/configurations/config.json
      cmp -s /etc/kea/config.json /tmp/configurations/config.json

      if [ $? -ne 0 ]; then
        echo "Configuration changes detected. Copying in place and updating Kea"
        cp /tmp/configurations/config.json /etc/kea/config.json
        curl -X "POST" "http://localhost:8000/" \
            -H 'Content-Type: application/json' \
            -d '{"command": "config-reload"}'
      else
        echo "No configuration changes detected"
      fi

      sleep 300
    done &
  fi
}

main() {
  fetch_kea_config
  configure_database_credentials /etc/kea/config.json
  ensure_database_permissions
  init_schema_if_not_loaded
  boot_control_agent
  boot_server
  touch /tmp/kea_started
  if [[ "$PUBLISH_METRICS" == "true" ]]; then
    boot_metrics_agent
  fi
  start_kea_config_reload_daemon
  fg %2 #KEA is running as a daemon, bring it back as the essential task of the container now that testing is finished
}

main
