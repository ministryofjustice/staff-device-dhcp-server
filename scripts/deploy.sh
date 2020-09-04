#!/bin/bash

set -e

outputs=${DHCP_DNS_TERRAFORM_OUTPUTS} | jq -r .dhcp | jq -r .ecs

dhcp_server_cluster_name=`echo $outputs | jq .cluster_name`
dhcp_server_service_name=`echo $outputs | jq .service_name`
dhcp_server_task_definition_name=`echo $outputs | jq .task_definition_name`

aws ecs update-service \
  --cluster $dhcp_server_cluster_name \
  --service $dhcp_server_service_name \
  --task-definition $dhcp_server_task_definition_name \
  --force-new-deployment
