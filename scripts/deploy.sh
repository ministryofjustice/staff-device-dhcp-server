#!/bin/bash

set -eo

outputs=$DHCP_DNS_TERRAFORM_OUTPUTS | jq -r .ecs

DHCP_SERVER_CLUSTER_NAME=`echo $outputs | jq .dhcp_cluster_name`
DHCP_SERVER_SERVICE_NAME=`echo $outputs | jq .dhcp_service_name`
DHCP_SERVER_TASK_DEFINITION_NAME=`echo $outputs | jq .dhcp_task_definition_name`

aws ecs update-service \
  --cluster $DHCP_SERVER_CLUSTER_NAME \
  --service $DHCP_SERVER_SERVICE_NAME \
  --task-definition $DHCP_SERVER_TASK_DEFINITION_NAME  \
  --force-new-deployment
