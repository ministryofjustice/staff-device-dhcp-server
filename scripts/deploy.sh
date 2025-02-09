#!/bin/bash

# This deployment script starts a zero downtime phased deployment.
# It works by doubling the currently running tasks by introducing the new versions
# Auto scaling will detect that there are too many tasks running for the current load and slowly start decomissioning the old running tasks
# Production traffic will gradually be moved to the new running tasks

set -euo pipefail

assume_deploy_role() {
  TEMP_ROLE=`aws sts assume-role --role-arn $ROLE_ARN --role-session-name ci-dhcp-deploy-$CODEBUILD_BUILD_NUMBER`
  export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
}

deploy() {
  cluster_name=$( jq -r '.dhcp.ecs.cluster_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )
  primary_service_name=$( jq -r '.dhcp.ecs.service_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )
  standby_service_name=$( jq -r '.dhcp_standby.ecs.service_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )
  api_service_name=$( jq -r '.dhcp_api.ecs.service_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )

  echo "deploying KEA Standby"
  aws ecs update-service \
    --cluster $cluster_name \
    --service $standby_service_name \
    --force-new-deployment

  echo "deploying KEA API"
  aws ecs update-service \
    --cluster $cluster_name \
    --service $api_service_name \
    --force-new-deployment

  echo "deploying KEA PRIMARY"
  aws ecs update-service \
    --cluster $cluster_name \
    --service $primary_service_name \
    --force-new-deployment


  # Wait for the ECS service to stabilize (reach steady state) add --max-wait 600 to cap at 10 mins?
  echo "Waiting for ECS service's to reach steady state..."
  aws ecs wait services-stable --cluster "$cluster_name" --services "$standby_service_name" "$primary_service_name" "$api_service_name"

  if [ $? -eq 0 ]; then
    echo "All ECS have reached a steady state."
  else
    echo "An ECS has failed to reach steady state."
    exit 1
  fi
}

main() {
  assume_deploy_role
  deploy
}

main
