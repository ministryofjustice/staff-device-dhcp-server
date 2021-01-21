require_relative 'spec_helper'
require_relative "../kea_subnet_id_to_cidr"
require "json"

describe KeaSubnetIdToCidr do
  it "returns a cidr when given a subnet id" do
    expected_result = "10.0.0.0/8"

    kea_client = double(get_config: JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_config_get_response.json")))
    result = described_class.new(kea_client: kea_client).execute(subnet_id: 1)
    expect(result).to eq(expected_result)
  end

  it "returns a different cidr when given a subnet id" do
    expected_result = "192.0.2.0/24"

    kea_client = double(get_config: JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_config_get_response.json")))
    result = described_class.new(kea_client: kea_client).execute(subnet_id: 2)
    expect(result).to eq(expected_result)
  end

  it "Should return static value for deleted subnet" do
    kea_client = double(get_config: [{"arguments" => {"Dhcp4" => {"subnet4" => []}}}])
    result = described_class.new(kea_client: kea_client).execute(subnet_id: 2)
    expect(result).to be_nil
  end
end
