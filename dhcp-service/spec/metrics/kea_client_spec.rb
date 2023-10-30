require_relative '../spec_helper'
require_relative "../../metrics/kea_client"

describe KeaClient do
  before do
    stub_request(:post, "http://localhost:8000/").
      with(
        body: "{\"command\":\"statistic-get-all\",\"service\":[\"dhcp4\"]}"
      ).to_return(status: 200, body: "{}", headers: {})

    stub_request(:post, "http://localhost:8000/").
      with(
        body: "{\"command\":\"config-get\",\"service\":[\"dhcp4\"]}").
      to_return(status: 200, body: "{}", headers: {})

  end

  it "gets statistics" do
    described_class.new.get_statistics
  end

  it "gets the config" do
    described_class.new.get_config
  end
end
