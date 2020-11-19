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
        generate_cloudwatch_metrics(kea_stats)
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
