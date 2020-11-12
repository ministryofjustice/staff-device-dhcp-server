require 'aws-sdk-cloudwatch'
require "net/http"
require "json"
require_relative "publish_metrics"
require_relative "aws_client"

while true do
  uri = URI.parse("http://localhost:8000/")

  req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
  req.body = { command: "statistic-get-all", service: ["dhcp4"] }.to_json
  http = Net::HTTP.new(uri.host, uri.port)
  kea_stats = JSON.parse(http.request(req).body)

  p "KEA stats: #{kea_stats}"
  PublishMetrics.new(client: AwsClient.new).execute(kea_stats: kea_stats)
  sleep 10
end
