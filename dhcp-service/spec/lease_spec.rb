require_relative "spec_helper"
require_relative "../metrics/db_client"
require 'sequel'

describe "getting leases" do
  let(:db_client) { DbClient.new.db }

  before do
    db_client[:lease4].truncate
    db_client.disconnect
  end

  after { db_client.disconnect }

  context "when 10 ordinary cliens are requesting IPs" do
    it "leases out 10 leases and leases persist in the DB" do
      `perfdhcp -r 2 \
        -n 10 \
        -R 10 \
        -d 2 \
        -4 \
        -W 20000000 \
        172.1.0.10`

      expect(db_client[:lease4].count).to eq(10)
    end
  end

  context "when MoJO devices with delivery optimisation enabled requesting IPs" do
    let(:expected_lease_options) { File.read("./spec/fixtures/expected_lease_options.txt") }
    let(:dhcp_offer_packet_content) { `tshark -r ./leases.pcap -V -T text` }

    before { Process.fork { `tshark -iany -f 'ip src 172.1.0.10 and udp port 67' -w ./leases.pcap -q -a packets:1` } }

    it "leases out a lease with device specific dhcp options" do
      `perfdhcp -r 2 \
        -n 3 \
        -R 1 \
        -b mac=00:0c:01:02:03:04 \
        -d 2 \
        -4 \
        -o 55,00EA \
        -W 20000000 \
        172.1.0.10`

      expect(dhcp_offer_packet_content).to include(expected_lease_options)
    end
  end
end
