#! /bin/sh

INTERFACE=eth0
DB_NAME=kea
DB_USER=kea
DB_PASS=kea
DB_HOST=db
DB_PORT=3306


sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json

kea-dhcp4 -c /etc/kea/config.json