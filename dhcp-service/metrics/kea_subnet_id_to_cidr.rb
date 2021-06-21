class KeaSubnetIdToCidr
  def initialize(kea_client:)
    @kea_client = kea_client
  end

  def execute(subnet_id:)
    result = subnets_config.find { |row| subnet_id.to_s == row["id"].to_s }

    if result.nil?
      p "Subnet #{subnet_id} not found" and return
    end

    result.fetch("subnet")
  end

  private

  def config
    @config ||= kea_client.get_config[0].fetch("arguments", {})
  end


  def base_subnets_config
    config.dig("Dhcp4", "subnet4") || []
  end

  def shared_networks_config
    config.dig("Dhcp4", "shared-networks") || []
  end

  def shared_networks_subnets_config
    shared_networks_config
      .map { |shared_network| shared_network["subnet4"] }
      .flatten
  end

  def subnets_config
    base_subnets_config + shared_networks_subnets_config
  end

  attr_reader :kea_client
end
