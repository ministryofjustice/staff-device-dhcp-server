#!/bin/bash

# This deployment script starts a zero downtime phased deployment.
# It works by doubling the currently running tasks by introducing the new versions
# Auto scaling will detect that there are too many tasks running for the current load and slowly start decomissioning the old running tasks
# Production traffic will gradually be moved to the new running tasks

set -e

deploy() {
  cluster_name=$( jq -r '.dhcp.ecs.cluster_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )
  service_name=$( jq -r '.dhcp.ecs.service_name' <<< "${DHCP_DNS_TERRAFORM_OUTPUTS}" )

  aws ecs update-service \
    --cluster $cluster_name \
    --service $service_name \
    --force-new-deployment
}

assume_deploy_role() {
  TEMP_ROLE=`aws sts assume-role --role-arn $ROLE_ARN --role-session-name ci-dhcp-deploy-$CODEBUILD_BUILD_NUMBER`
  export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
}

main() {
  assume_deploy_role
  deploy
}

main
