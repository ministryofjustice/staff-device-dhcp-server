#! /bin/sh

sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json

kea-dhcp4 -c /etc/kea/config.json