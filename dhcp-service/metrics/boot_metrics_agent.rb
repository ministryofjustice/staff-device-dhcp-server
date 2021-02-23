require 'aws-sdk-cloudwatch'
require "net/http"
require "json"
require "sentry-ruby"
require_relative "publish_metrics"
require_relative "aws_client"
require_relative "kea_client"
require_relative "db_client"
require_relative "kea_lease_usage"
require_relative "kea_subnet_id_to_cidr"

Sentry.init do |config|
  # All errors will be sent syncronously!
  config.background_worker_threads = 0
  config.environment = ENV["SENTRY_CURRENT_ENV"]
end

class Agent
  def execute
    loop do
      kea_subnet_id_to_cidr = KeaSubnetIdToCidr.new(kea_client: kea_client)

      PublishMetrics.new(
        client: AwsClient.new,
        kea_lease_usage: kea_lease_usage,
        kea_subnet_id_to_cidr: kea_subnet_id_to_cidr
      ).execute(kea_stats: kea_client.get_statistics)
      sleep 10
    end
  rescue => e
    Sentry.capture_exception(e)
    raise e
  end

  private

  def kea_client
    @kea_client ||= KeaClient.new
  end

  def db_client
    @db_client ||= DbClient.new
  end

  def kea_lease_usage
    @kea_lease_usage ||= KeaLeaseUsage.new(
      kea_client: kea_client,
      db_client: db_client
    )
  end
end

Agent.new.execute
