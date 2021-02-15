require 'time'

class PublishMetrics
  def initialize(client:, kea_lease_usage:, kea_subnet_id_to_cidr:)
    @client = client
    @kea_lease_usage = kea_lease_usage
    @kea_subnet_id_to_cidr = kea_subnet_id_to_cidr
    @time = DateTime.now.to_time.to_i
  end

  def execute(kea_stats:)
    raise "Kea stats are empty" if kea_stats.empty?

    return if kea_stats[0]["arguments"].nil?

    client.put_metric_data(
      with_percent_used(generate_cloudwatch_metrics(kea_stats)))
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

  def subnet_id_to_cidr(subnet_id)
    kea_subnet_id_to_cidr.execute(subnet_id: subnet_id)
  end

  def with_percent_used(metrics)
    kea_lease_usage.execute.each do |kea_metric|
      subnet_cidr = subnet_id_to_cidr(kea_metric.fetch(:subnet_id))
      unless subnet_cidr.nil?
        metrics << {
          metric_name: "lease-percent-used",
          timestamp: @time,
          value: kea_metric.fetch(:usage_percentage),
          dimensions: [
            {
               name: "Subnet",
               value: subnet_cidr
            },
            {
               name: "Server",
               value: ENV.fetch("SERVER_NAME")
            }
          ]
        }
      end
    end

    metrics
  end

  IGNORED_METRICS = [
    "pkt4-sent",
    "pkt4-inform-received",
    "pkt4-parse-failed",
    "pkt4-received",
    "declined-reclaimed-addresses",
    "total-addresses"
  ]

  attr_reader :client, :kea_lease_usage, :kea_subnet_id_to_cidr
end
