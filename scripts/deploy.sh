#!/bin/bash

set -e

output=$( jq -r '.dhcp.ecs' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )

cluster_name=$( jq '.cluster_name' <<< "${output}" )
service_name=$( jq '.service_name' <<< "${output}" )
task_definition_name=$( jq '.task_definition_name' <<< "${output}" )

aws ecs update-service \
  --cluster $cluster_name \
  --service $service_name \
  --task-definition $task_definition_name \
  --force-new-deployment
