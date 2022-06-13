require_relative '../spec_helper'
require_relative "../../metrics/kea_lease_usage"
require "json"

describe KeaLeaseUsage do
  let(:kea_client) { double(get_leases: JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_stat_lease4_response.json"))) }
  let(:db_client) do
    double(get_lease_stats: [
      {
        subnet_id: 1,
        state: 0,
        leases: 100
      },
      {
        subnet_id: 2,
        state: 0,
        leases: 200
      },
      {
        subnet_id: 3,
        state: 0,
        leases: 512
      },
      {
        subnet_id: 4,
        state: 0,
        leases: 400
      },
      {
        subnet_id: 5,
        state: 0,
        leases: 500
      },
      {
        subnet_id: 6,
        state: 0,
        leases: 0
      }
    ])
  end
  let(:result) do
    described_class.new(
      kea_client: kea_client,
      db_client: db_client
    ).execute
  end

  describe "when the subnets are available in memory stats and the db" do
    it "returns leases" do
      expected_result = [
        {
          subnet_id: 3,
          assigned_addresses: 512,
          total_addresses: 1024,
          declined_addresses: 0,
          usage_percentage: 50
        },
        {
          subnet_id: 5,
          assigned_addresses: 500,
          total_addresses: 1024,
          declined_addresses: 4,
          usage_percentage: 49
        },
        {
          subnet_id: 4,
          assigned_addresses: 400,
          total_addresses: 1024,
          declined_addresses: 4,
          usage_percentage: 39
        },
        {
          subnet_id: 2,
          assigned_addresses: 200,
          total_addresses: 1024,
          declined_addresses: 4,
          usage_percentage: 20
        },
        {
          subnet_id: 1,
          assigned_addresses: 100,
          total_addresses: 1024,
          declined_addresses: 0,
          usage_percentage: 10
        }
      ]

      expect(result).to eq(expected_result)
    end

    it "only selects the top 5 based on usage" do
      expect(result.count).to eq(5)
    end
  end

  describe "when a subnet exists in the db but not the in memory stats" do
    let(:db_client) do
      double(get_lease_stats: [
        {
          subnet_id: 7,
          state: 0,
          leases: 100
        }
      ])
    end

    it "does not publish metrics for that subnet" do
      expect(result).to eq([])
    end
  end
end
