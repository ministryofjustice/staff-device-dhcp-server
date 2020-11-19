require 'rspec'
require 'webmock/rspec'
require_relative '../ecs_metadata_client'

describe EcsMetadataClient do
  before do
    ENV["ECS_CONTAINER_METADATA_URI"] = "http://169.254.170.2/metadata"

    stub_request(:get, ENV['ECS_CONTAINER_METADATA_URI']).
    to_return(body: File.read("/metrics/spec/fixtures/ecs_container_metadata.json"))
  end

  it "fetches the task_id from the container metadata" do
    expected_result = {
      task_id: '6d52d2abc39fb7212c9a0a23135d6a2997f22a7f9475106d8e8bbc95ef3e4c88'
    }

    expect(described_class.new(endpoint: ENV["ECS_CONTAINER_METADATA_URI"]).execute).to eq(expected_result)
  end
end
