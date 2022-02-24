#!/bin/bash
# -m for job control within a bash script (used to foreground server after testing)

set -me

fetch_kea_config() {
  if [ "$SERVER_NAME" == "api" ]; then
    echo "Booting as API"
    cp ./config_api.json /etc/kea/config.json
  elif [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    echo "Booting local server"
    cp ./test_config.json /etc/kea/config.json
  else
    echo "Booting HA peer server"
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
  echo "Start of the Kea DB initialisation process:"
  db_version=$(kea-admin db-version mysql -u ${DB_USER} -p ${DB_PASS} -n ${DB_NAME} -h ${DB_HOST}) || echo "Kea DB not configured"
  if [[ "$db_version" == *"Failed to get schema version"* ]]; then
    echo "Kea DB is not initialised"
    echo "Initialising now............"
    $(kea-admin db-init mysql -u ${DB_USER} -p ${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} &> /dev/null)
    echo "Kea DB is now initialised"
  else
    echo "Kea DB is already initialised"
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
  while [ true ]; do
    echo "Checking for new configurations..."
    aws s3 sync s3://${KEA_CONFIG_BUCKET_NAME} /tmp/configurations --exclude "*" --include "config.json"
    configure_database_credentials /tmp/configurations/config.json

    status=0
    cmp -s /etc/kea/config.json /tmp/configurations/config.json || status=$?

    if [ $status -ne 0 ]; then
      echo "Configuration changes detected. Copying in place and updating Kea"
      cp /tmp/configurations/config.json /etc/kea/config.json
      curl -X "POST" "http://localhost:8000/" \
          -H 'Content-Type: application/json' \
          -d '{"command": "config-reload", "service": ["dhcp4"]}'
    else
      echo "No configuration changes detected"
    fi

    sleep 300
  done &
}

main() {
  fetch_kea_config
  configure_database_credentials /etc/kea/config.json
  if [[ "$LOCAL_DEVELOPMENT" != "true" ]] && [[ "$SERVER_NAME" == "primary" ]]; then
    ensure_database_permissions
  fi
  init_schema_if_not_loaded
  boot_control_agent
  boot_server
  touch /tmp/kea_started
  if [[ "$PUBLISH_METRICS" == "true" ]]; then
    boot_metrics_agent
  fi
  if [[ "$LOCAL_DEVELOPMENT" != "true" ]] && [[ "$SERVER_NAME" != "api" ]]; then
    start_kea_config_reload_daemon
  fi
  fg %2 #KEA is running as a daemon, bring it back as the essential task of the container now that testing is finished
}

main
