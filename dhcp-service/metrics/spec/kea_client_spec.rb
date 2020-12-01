require 'rspec'
require 'webmock/rspec'
require_relative "../kea_client"

describe KeaClient do
  before do
    stub_request(:post, "http://localhost:8000/").
    with(
      body: "{\"command\":\"stat-lease4-get\",\"service\":[\"dhcp4\"]}").
    to_return(status: 200, body: "{}", headers: {})

    stub_request(:post, "http://localhost:8000/").
      with(
        body: "{\"command\":\"statistic-get-all\",\"service\":[\"dhcp4\"]}"
      ).to_return(status: 200, body: "{}", headers: {})
  end

  it "gets leases" do
    described_class.new.get_leases
  end

  it "gets statistics" do
    described_class.new.get_statistics
  end
end
