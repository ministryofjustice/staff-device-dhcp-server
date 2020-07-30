#! /bin/sh

if [ -z "$CONFIG_URL" ]; then
  echo "Using default config. No CONFIG_URL provided"
else
  wget --quiet --spider $CONFIG_URL
  if [ $? -eq 0 ] ; then
      echo "Fetching new config from ${CONFIG_URL}"
      wget -nv $CONFIG_URL -O /etc/kea/config.json
  else
    echo "Using default config. New config not found"
  fi
fi

sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json

kea-admin db-init mysql -u $DB_USER -p $DB_PASS -n $DB_NAME -h $DB_HOST > /dev/null
kea-dhcp4 -c /etc/kea/config.json
