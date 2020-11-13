require 'time'

class PublishMetrics
  def initialize(client:)
    @client = client
  end

  def execute(kea_stats:)
    raise "Kea stats are empty" if kea_stats.empty?

    client.put_metric_data(
      generate_cloudwatch_metrics(kea_stats)
    )
  end

  private

  def generate_cloudwatch_metrics(kea_stats)
    kea_stats[0].fetch("arguments").map { |argument| generate_metric(argument) }
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
    time = DateTime.now.to_time.to_i

    if subnet_metric?(metric_name)
      metric_name = metric_name.split(".")[1]
      metric[:dimensions] = [
        {
          name: "Subnet",
          value: row[0][/\d+/]
        }
      ]
      metric[:timestamp] = time
    end

    metric[:metric_name] = metric_name
    metric[:timestamp] = time
    metric[:value] = value

    metric
  end

  attr_reader :client
end
