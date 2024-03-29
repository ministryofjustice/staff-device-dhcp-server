require 'aws-sdk-cloudwatch'
require "net/http"
require "json"
require "sentry-ruby"
require_relative "publish_metrics"
require_relative "aws_client"
require_relative "kea_client"

if ENV["SENTRY_DSN"]
  Sentry.init do |config|
    # All errors will be sent syncronously!
    config.background_worker_threads = 0
    config.environment = ENV["SENTRY_CURRENT_ENV"]
  end
end

class Agent
  def execute
    loop do
      PublishMetrics.new(
        client: AwsClient.new
      ).execute(
        kea_stats: kea_client.get_statistics
      )
      sleep 10
    end
  rescue => e
    if ENV["SENTRY_DSN"]
      Sentry.capture_exception(e)
    end
    raise e
  end

  private

  def kea_client
    @kea_client ||= KeaClient.new
  end
end

Agent.new.execute
