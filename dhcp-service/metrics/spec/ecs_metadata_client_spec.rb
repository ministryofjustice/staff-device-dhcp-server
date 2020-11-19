require 'rspec'
require 'webmock/rspec'
require_relative '../ecs_metadata_client'

describe EcsMetadataClient do
  before do
    ENV["ECS_CONTAINER_METADATA_URI"] = "169.254.170.2"

    stub_request(:get, "#{ENV['ECS_CONTAINER_METADATA_URI']}/v2/metadata").
    to_return(body: File.read("/metrics/spec/fixtures/ecs_container_metadata.json"))
  end

  it "fetches the task_id from the container metadata" do
    expected_result = {
      task_id: '731a0d6a3b4210e2448339bc7015aaa79bfe4fa256384f4102db86ef94cbbc4c'
    }

    expect(described_class.new(endpoint: ENV["ECS_CONTAINER_METADATA_URI"]).execute).to eq(expected_result)
  end
end
