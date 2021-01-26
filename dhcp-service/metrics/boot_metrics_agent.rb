require 'aws-sdk-cloudwatch'
require "net/http"
require "json"
require_relative "publish_metrics"
require_relative "aws_client"
require_relative "kea_client"
require_relative "db_client"
require_relative "kea_lease_usage"
require_relative "kea_subnet_id_to_cidr"

kea_client = KeaClient.new
db_client = DbClient.new
kea_subnet_id_to_cidr = KeaSubnetIdToCidr.new(kea_client: kea_client)
kea_lease_usage = KeaLeaseUsage.new(kea_client: kea_client, db_client: db_client)

while true do
  PublishMetrics.new(
    client: AwsClient.new,
    kea_lease_usage: kea_lease_usage,
    kea_subnet_id_to_cidr: kea_subnet_id_to_cidr
  ).execute(kea_stats: kea_client.get_statistics)
  sleep 10
end
