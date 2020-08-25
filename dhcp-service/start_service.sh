#! /bin/bash

if [[ $ENVIRONMENT == "development" ]]; then
    cp ./test_config.json /etc/kea/config.json
else
    aws s3 cp s3://${KEA_CONFIG_BUCKET_NAME}/config.json /etc/kea/config.json
fi

sed -i "s/<INTERFACE>/$INTERFACE/g" /etc/kea/config.json
sed -i "s/<DB_NAME>/$DB_NAME/g" /etc/kea/config.json
sed -i "s/<DB_USER>/$DB_USER/g" /etc/kea/config.json
sed -i "s/<DB_PASS>/$DB_PASS/g" /etc/kea/config.json
sed -i "s/<DB_HOST>/$DB_HOST/g" /etc/kea/config.json
sed -i "s/<DB_PORT>/$DB_PORT/g" /etc/kea/config.json

kea-admin db-init mysql -u $DB_USER -p $DB_PASS -n $DB_NAME -h $DB_HOST > /dev/null
echo "Starting DHCP server..."
kea-dhcp4 -c /etc/kea/config.json
