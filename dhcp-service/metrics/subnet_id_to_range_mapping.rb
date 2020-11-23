require 'json'

class SubnetIdToRangeMapping
  def initialize(config_api_client:)
    @config_api_client = config_api_client
  end

  def execute
    kea_config = config_api_client.get_config
    payload(kea_config)
  end

  private

  def payload(kea_config)
    subnet_config = kea_config[0].fetch("arguments").fetch("Dhcp4").fetch("subnet4")

    subnet_config.map do |config|
      {
        id: config.fetch("id"),
        subnet: config.fetch("subnet")
      }
    end
  end

  attr_reader :config_api_client
end
