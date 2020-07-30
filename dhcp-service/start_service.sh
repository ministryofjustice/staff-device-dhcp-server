#! /bin/sh

echo "Before fetching config file"
wget https://staff-device-andy-dhcp-config-bucket.s3.eu-west-2.amazonaws.com/config.json -P /etc/kea
echo "After fetching config file"

sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json

kea-admin db-init mysql -u $DB_USER -p $DB_PASS -n $DB_NAME -h $DB_HOST > /dev/null
kea-dhcp4 -c /etc/kea/config.json
