require 'net/http'

class EcsMetadataClient
  def initialize(endpoint:)
    @endpoint = endpoint
  end

  def execute
    result = Net::HTTP.get(endpoint, '/v2/metadata')

    payload(JSON.parse(result))
  end

  private

  def payload(parsed_response)
    containers_response = parsed_response.fetch("Containers")
    container = containers_response.find do |container_response|
      container_response.fetch("Name") == "dhcp-server"
    end

    {
      task_id: container.fetch("DockerId")
    }
  end

  attr_reader :endpoint
end
