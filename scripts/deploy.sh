#!/bin/bash

# This deployment script starts a zero downtime phased deployment.
# It works by doubling the currently running tasks by introducing the new versions
# Auto scaling will detect that there are too many tasks running for the current load and slowly start decomissioning the old running tasks
# Production traffic will gradually be moved to the new running tasks

set -e

cluster_name=$( jq -r '.dhcp.ecs.cluster_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )
service_name=$( jq -r '.dhcp.ecs.service_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )

aws ecs update-service \
  --cluster $cluster_name \
  --service $service_name \
  --force-new-deployment
