#! /bin/sh

if [ -n "$KEA_CONFIG_URL" ]; then
  echo "Checking for config at ${KEA_CONFIG_URL}"
  wget --quiet --spider --timeout=60 $KEA_CONFIG_URL

  if [ $? -eq 0 ] ; then
      echo "Found config. Fetching from ${KEA_CONFIG_URL}"
      wget -nv --timeout=60 $KEA_CONFIG_URL -O /etc/kea/config.json
  else
    echo "Config at ${KEA_CONFIG_URL} not found. Exiting."
    exit 1
  fi
else
  echo "No KEA_CONFIG_URL provided. Exiting"
  exit 1
fi

sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json

kea-admin db-init mysql -u $DB_USER -p $DB_PASS -n $DB_NAME -h $DB_HOST > /dev/null
kea-dhcp4 -c /etc/kea/config.json
