class KeaSubnetIdToCidr
  def initialize(kea_client:)
    @kea_client = kea_client
  end

  def execute(subnet_id:)
    p "subnet id is: #{subnet_id}"

    result = config.find do |row|
      p "comparing: #{subnet_id.to_s} to #{row.fetch("id").to_s}"

      subnet_id.to_s == row.fetch("id").to_s
    end

    p "row is: #{result}"
    result["subnet"]
  end

  private

  def config
    @config ||= kea_client.get_config[0]["arguments"]["Dhcp4"]["subnet4"]
    p @config
    @config
  end

  attr_reader :kea_client
end
