require 'aws-sdk-cloudwatch'
require "net/http"
require "json"
require_relative "publish_metrics"
require_relative "aws_client"
require_relative "kea_client"
require_relative "kea_lease_usage"

while true do
  kea_stats = KeaClient.new.get_statistics
  kea_lease_usage = KeaLeaseUsage.new(kea_client: KeaClient.new)

  PublishMetrics.new(
    client: AwsClient.new,
     kea_lease_usage: kea_lease_usage,
    ).execute(kea_stats: kea_stats)
  sleep 10
end
