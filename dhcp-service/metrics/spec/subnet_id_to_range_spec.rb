require_relative "../subnet_id_to_range"

describe SubnetIdToRange do
  it "maps a subnet ID to a subnet range" do
    config_api_client = double(get_config: File.read("/metrics/spec/fixtures/kea_api_config_get_response.json"))
    result = described_class.new(config_api_client: config_api_client).execute

    expect(result).to eq(
      [
        {
          id: 1,
          subnet: "127.0.0.1/16"
        }, {
          id: 2,
          subnet: "10.0.0.1/16"
        }
      ]
    )
  end
end
