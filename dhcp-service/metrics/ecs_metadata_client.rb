require 'net/http'

class EcsMetadataClient
  def initialize(endpoint:)
    @endpoint = endpoint
  end

  def execute
    payload(JSON.parse(Net::HTTP.get(URI.parse(URI.escape(endpoint)))))
  end

  private

  def payload(parsed_response)
    {
      task_id: parsed_response.fetch("DockerId")[0,7]
    }
  end

  attr_reader :endpoint
end
