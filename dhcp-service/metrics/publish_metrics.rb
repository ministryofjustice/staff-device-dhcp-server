require 'time'

class PublishMetrics
  def initialize(client:)
    @client = client
    @time = DateTime.now.to_time.to_i
  end

  def execute(kea_stats:)
    raise "Kea stats are empty" if kea_stats.empty?

    return if kea_stats[0]["arguments"].nil?

    client.put_metric_data(generate_cloudwatch_metrics(kea_stats))
  end

  private

  def generate_cloudwatch_metrics(kea_stats)
    kea_stats[0].fetch("arguments").map { |argument| generate_metric(argument) }.compact
  end

  def subnet_metric?(key)
    key.match?(/subnet\[/)
  end

  def generate_metric(row)
    metric = {}
    metric_name = row[0]
    values = row[1]
    value = values[0][0]
    date = values[0][1]

    return if IGNORED_METRICS.include?(metric_name) or subnet_metric?(metric_name)

    metric[:dimensions] = [
      {
        name: "Server",
        value: ENV.fetch("SERVER_NAME")
      }
    ]
    metric[:metric_name] = metric_name
    metric[:timestamp] = @time
    metric[:value] = value

    metric
  end

  IGNORED_METRICS = [
    "pkt4-sent",
    "pkt4-inform-received",
    "pkt4-parse-failed",
    "pkt4-received",
    "declined-reclaimed-addresses",
    "total-addresses"
  ]

  attr_reader :client
end
