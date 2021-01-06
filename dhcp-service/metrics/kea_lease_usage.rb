class KeaLeaseUsage
  def initialize(kea_client:)
    @kea_client = kea_client
  end

  def execute
    lease_stats = kea_client.get_leases
    parsed_lease_stats = lease_stats[0]["arguments"]["result-set"]["rows"]

    top_5_lease_stats = parsed_lease_stats.sort_by do |stat|
      usage_percent(stat[1], stat[3])
    end.reverse.first(5)

    top_5_lease_stats.map do |lease_stat|
      total_addresses = lease_stat[1]
      assigned_addresses = lease_stat[3]

      {
        subnet_id: lease_stat[0],
        total_addresses: total_addresses,
        assigned_addresses: assigned_addresses,
        declined_addresses: lease_stat[4],
        usage_percentage: usage_percent(total_addresses, assigned_addresses)
      }
    end
  end

  private

  def usage_percent(total_addresses, assigned_addresses)
    ((assigned_addresses.to_f / total_addresses.to_f) * 100).round
  end

  attr_reader :kea_client, :kea_subnet_id_to_cidr
end
