require 'aws-sdk-cloudwatch'
require "net/http"
require "json"
require_relative "publish_metrics"
require_relative "aws_client"
require_relative "kea_client"
require_relative "kea_lease_usage"
require_relative "kea_subnet_id_to_cidr"

while true do
  kea_client = KeaClient.new
  kea_stats = kea_client.get_statistics
  kea_subnet_id_to_cidr = KeaSubnetIdToCidr.new(kea_client: kea_client)
  kea_lease_usage = KeaLeaseUsage.new(
    kea_client: kea_client,
    kea_subnet_id_to_cidr: kea_subnet_id_to_cidr
  )

  PublishMetrics.new(
    client: AwsClient.new,
     kea_lease_usage: kea_lease_usage,
     kea_subnet_id_to_cidr: kea_subnet_id_to_cidr
    ).execute(kea_stats: kea_stats)
  sleep 10
end
