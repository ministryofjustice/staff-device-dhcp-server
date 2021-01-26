require "sequel"

class KeaLeaseUsage
  def initialize(kea_client:, db_client:)
    @kea_client = kea_client
    @db_client = db_client
  end

  def execute
    lease_stats = kea_client.get_leases
    db_stats = db_client.get_lease_stats
    in_memory_stats = lease_stats[0]["arguments"]["result-set"]["rows"]

    all_parsed_metrics(db_stats, in_memory_stats)
      .compact
      .sort_by { |metric| - metric[:usage_percentage] }
      .first(5)
  end

  private

  def all_parsed_metrics(db_stats, in_memory_stats)
    db_stats.map do |db_stat|
      assigned_addresses = db_stat.fetch(:leases)
      api_lease_stat = in_memory_stats.find { |lease_stat| lease_stat[0] == db_stat.fetch(:subnet_id) }

      if api_lease_stat
        total_addresses = api_lease_stat[1]

        {
          subnet_id: api_lease_stat[0],
          total_addresses: total_addresses,
          assigned_addresses: assigned_addresses,
          declined_addresses: api_lease_stat[4],
          usage_percentage: usage_percent(total_addresses, assigned_addresses)
        }
      end
    end
  end

  def usage_percent(total_addresses, assigned_addresses)
    ((assigned_addresses.to_f / total_addresses.to_f) * 100).round
  end

  attr_reader :kea_client, :kea_subnet_id_to_cidr, :db_client
end
