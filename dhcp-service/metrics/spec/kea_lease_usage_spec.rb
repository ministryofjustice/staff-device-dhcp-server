require_relative 'spec_helper'
require_relative "../kea_lease_usage"
require "json"

describe KeaLeaseUsage do

  let(:kea_subnet_id_to_cidr) { double }

  it "returns leases" do
    allow(kea_subnet_id_to_cidr).to receive(:execute).with(subnet_id: 1).and_return("8.8.8.8/32")
    allow(kea_subnet_id_to_cidr).to receive(:execute).with(subnet_id: 1018).and_return("9.9.9.9/32")

    expected_result = [
      {
        subnet_id: "8.8.8.8/32",
        assigned_addresses: 111,
        total_addresses: 256,
        declined_addresses: 0,
        usage_percentage: 43
      },
      {
        subnet_id: "9.9.9.9/32",
        assigned_addresses: 2034,
        total_addresses: 4098,
        declined_addresses: 4,
        usage_percentage: 50
      }
    ]
    kea_client = double(get_leases: JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_stat_lease4_response.json")))

    result = described_class.new(kea_client: kea_client, kea_subnet_id_to_cidr: kea_subnet_id_to_cidr).execute

    expect(result).to eq(expected_result)
  end
end
