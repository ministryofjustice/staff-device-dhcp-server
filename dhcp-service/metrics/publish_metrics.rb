require 'time'

class PublishMetrics
  def initialize(client:, ecs_metadata_client:, kea_lease_usage:)
    @client = client
    @ecs_metadata_client = ecs_metadata_client
    @kea_lease_usage = kea_lease_usage
    @time = DateTime.now.to_time.to_i
  end

  def execute(kea_stats:)
    raise "Kea stats are empty" if kea_stats.empty?

    client.put_metric_data(
      with_percent_used(with_task_id(generate_cloudwatch_metrics(kea_stats))))
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

    metric[:dimensions] = []

    if subnet_metric?(metric_name)
      metric_name = metric_name.split(".")[1]
      metric[:dimensions] << { name: "Subnet", value: row[0][/\d+/] }
      metric[:timestamp] = @time
    end

    metric[:metric_name] = metric_name
    metric[:timestamp] = @time
    metric[:value] = value

    metric
  end

  def task_id
    @task_id ||= ecs_metadata_client.execute.fetch(:task_id)
  end

  def with_task_id(metrics)
    metrics.map do |metric|
      metric[:dimensions] << { name: "TaskID", value: task_id }

      metric
    end
  end

  def with_percent_used(metrics)
    percent_used_subnet_metrics = metrics.select do |metric|
      metric[:metric_name] == 'total-addresses'
    end.group_by do |metric|
      metric[:dimensions].select { |d| d[:name] == 'Subnet' }.first[:value]
    end

    kea_lease_usage.execute.each do |kea_metric|
      metrics << {
        metric_name: "lease-percent-used",
        timestamp: @time,
        value: kea_metric.fetch(:usage_percentage),
        dimensions: [ { name: "Subnet", value: kea_metric.fetch(:subnet_id).to_s } ]
      }
    end

    metrics
  end

  attr_reader :client, :ecs_metadata_client, :kea_lease_usage
end
