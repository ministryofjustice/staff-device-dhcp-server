require_relative "../kea_lease_usage"

describe KeaLeaseUsage do
  it "returns leases" do
    expected_result = [
      {
        subnet_id: 10,
        assigned_addresses: 111,
        total_addresses: 256,
        declined_addresses: 0,
        usage_percentage: 43
      },
      {
        subnet_id: 20,
        assigned_addresses: 2034,
        total_addresses: 4098,
        declined_addresses: 4,
        usage_percentage: 50
      }
    ]
    kea_client = double(get_leases: JSON.parse(File.read("/metrics/spec/fixtures/kea_api_stat_lease4_response.json")))
    result = described_class.new(kea_client: kea_client).execute
    expect(result).to eq(expected_result)
  end
end