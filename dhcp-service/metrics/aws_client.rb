require 'aws-sdk-cloudwatch'

class AwsClient
  REGION="eu-west-2"
  MAX_METRICS_PER_CLOUDWATCH_API_CALL=20

  def initialize(client: Aws::CloudWatch::Client.new(region: REGION), aws_config: {})
    @client = client
  end

  def put_metric_data(metrics)
    sliced(metrics).each do |metrics_slice|
      client.put_metric_data(
        namespace: "DHCP-Kea-Server",
        metric_data: metrics_slice
      )
    end
  end

  private

  def sliced(metrics)
    metrics.each_slice(MAX_METRICS_PER_CLOUDWATCH_API_CALL).to_a
  end

  attr_reader :client
end
