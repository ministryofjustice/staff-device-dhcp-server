require 'net/http'

class EcsMetadataClient
  def initialize(endpoint:)
    @endpoint = endpoint
  end

  def execute
    escaped_endpoint = URI.escape(endpoint)
    uri = URI.parse(escaped_endpoint)

    result = Net::HTTP.get(uri)

    payload(JSON.parse(result))
  end

  private

  def payload(parsed_response)
    {
      task_id: parsed_response.fetch("DockerId")[0..6]
    }
  end

  attr_reader :endpoint
end
