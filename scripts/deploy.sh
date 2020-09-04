#!/bin/bash

# This deployment script starts a zero downtime phased deployment.
# It works by doubling the currently running tasks by introducing the new versions
# Auto scaling will detect that there are too many tasks running for the current load and slowly start decomissioning the old running tasks
# Production traffic will gradually be moved to the new running tasks


set -e

output=$( jq -r '.dhcp.ecs' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )

cluster_name=$( jq -r '.cluster_name' <<< "${output}" )
service_name=$( jq -r '.service_name' <<< "${output}" )

aws ecs update-service \
  --cluster $cluster_name \
  --service $service_name \
  --force-new-deployment
