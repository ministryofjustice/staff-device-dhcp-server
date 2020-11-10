require 'aws-sdk-cloudwatch'

class AwsClient
  REGION="eu-west-2"

  def initialize(client: Aws::CloudWatch::Client.new(region: REGION), aws_config: {})
    @client = client
  end

  def put_metric_data(metrics)
    sliced(metrics).each do |metrics_slice|
      client.put_metric_data(
        namespace: "Kea-DHCP-Server",
        metric_data: metrics_slice
      )
    end
  end

  private

  def sliced(metrics)
    metrics.each_slice(20).to_a
  end

  attr_reader :client
end
