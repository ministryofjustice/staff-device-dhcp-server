#!/bin/bash

if [ "$LOCAL_DEVELOPMENT" != "true" ]; then
  while [ true ]; do
    echo "Checking for new configurations..."
    aws s3 sync s3://${KEA_CONFIG_BUCKET_NAME} /tmp/configurations --exclude "*" --include "config.json"
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
  done
fi
