class KeaSubnetIdToCidr
  def initialize(kea_client:)
    @kea_client = kea_client
  end

  def execute(subnet_id:)
    subnet_rows = kea_client.get_config[0]["arguments"]["Dhcp4"]["subnet4"]

    subnet_rows.find { |row| subnet_id.to_s == row.fetch("id").to_s }["subnet"]
  end

  private

  attr_reader :kea_client
end
