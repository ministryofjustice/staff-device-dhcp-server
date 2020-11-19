require 'time'

class PublishMetrics
  def initialize(client:, ecs_metadata_client:)
    @client = client
    @ecs_metadata_client = ecs_metadata_client
  end

  def execute(kea_stats:)
    raise "Kea stats are empty" if kea_stats.empty?

    client.put_metric_data(
      with_task_id(
        with_percent_used(
          generate_cloudwatch_metrics(kea_stats)
        )
      )
    )
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
    time = DateTime.now.to_time.to_i

    metric[:dimensions] = []

    if subnet_metric?(metric_name)
      metric_name = metric_name.split(".")[1]

      metric[:dimensions] << {
          name: "Subnet",
          value: row[0][/\d+/]
        }
      metric[:timestamp] = time
    end

    metric[:metric_name] = metric_name
    metric[:timestamp] = time
    metric[:value] = value

    metric
  end

  def with_percent_used(metrics)
    percent_used_subnet_metrics = metrics.select do |metric|
      metric[:metric_name] == 'total-addresses' or metric[:metric_name] == 'assigned-addresses'
    end.group_by { |metric| metric[:dimensions].select { |d| d[:name] == 'Subnet' }.first[:value] }

    percent_used_subnet_metrics.each do |k,v|
      total_addresses = v.find { |m| m[:metric_name] == 'total-addresses' }[:value]
      assigned_addresses = v.find { |m| m[:metric_name] == 'assigned-addresses' }[:value] || 0

      percent_used = assigned_addresses == 0 ? 0 : ((assigned_addresses.to_f / total_addresses.to_f) * 100).round

      pp "total_addresses = #{total_addresses}
      assigned_addresses = #{assigned_addresses}
      percent_used = #{percent_used}
      subnet = #{k}"

      metrics << {
        metric_name: 'lease-percent-used',
        dimensions: [
        {
          name: 'Subnet',
          value: k,
        }
      ],
        value: percent_used,
        timestamp: v[0][:timestamp]
      }
    end

    metrics
  end

  def task_id
    @task_id ||= ecs_metadata_client.execute.fetch(:task_id)
  end

  def with_task_id(metrics)
    metrics.map do |metric|
      metric[:dimensions] << {
        name: "TaskID",
        value: task_id
      }

      metric
    end
  end

  IGNORED_METRICS = [
    'pkt4-sent',
    'pkt4-received',
    'cumulative-assigned-addresses',
    'declined-addresses',
    'declined-reclaimed-addresses',
    'reclaimed-declined-addresses',
    'reclaimed-leases'
  ]
  attr_reader :client, :ecs_metadata_client
end
