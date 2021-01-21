class KeaSubnetIdToCidr
  def initialize(kea_client:)
    @kea_client = kea_client
  end

  def execute(subnet_id:)
    result = config.find { |row| subnet_id.to_s == row["id"].to_s }

    if result.nil?
      p "Subnet #{subnet_id} not found" and return
    end

    result.fetch("subnet")
  end

  private

  def config
    @config ||= kea_client.get_config[0]["arguments"]["Dhcp4"]["subnet4"]
  end

  attr_reader :kea_client
end
