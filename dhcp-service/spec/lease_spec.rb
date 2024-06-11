require_relative "spec_helper"
require_relative "../metrics/db_client"
require 'sequel'

describe "Kea server" do
  let(:db_client) { DbClient.new.db }
  let(:dhcp_offer_packet_content) { `tshark -r ./dhcp_offer_packet.pcap -V -T text` }

  before do
    db_client[:lease4].truncate
    db_client.disconnect
    Process.fork { `tshark -iany -f 'ip src 172.1.0.10 and udp port 67' -w ./dhcp_offer_packet.pcap -q -a packets:1` }
    sleep 10 # Adding a delay to ensure the process is ready
  end

  after { db_client.disconnect }

  context "when ordinary dhcp clients send DHCP requests" do
    it "provides 10 leases to 10 clients, leases persist in the DB and provides DHCP options from global options" do
      `perfdhcp -r 2 \
        -n 10 \
        -R 10 \
        -d 2 \
        -4 \
        -W 20000000 \
        172.1.0.10`
      sleep 10
      expect(db_client[:lease4].count).to eq(10)
      expect(dhcp_offer_packet_content).to include(File.read("./spec/fixtures/expected_lease_options_ordinary.txt"))
      expect(dhcp_offer_packet_content).not_to include("Option: (234) Private")
    end
  end

  context "when Windows 10 devices with client class value of 'W10TEST' send DHCP requests" do
    it "provides a lease with DHCP options from global options but overrides dns-name option from client class options" do
      `perfdhcp -r 2 \
        -n 3 \
        -R 1 \
        -b mac=00:0c:01:02:03:04 \
        -d 2 \
        -4 \
        -o 77,57313054455354 \
        -W 20000000 \
        172.1.0.10`
      sleep 5
      expect(dhcp_offer_packet_content).to include(File.read("./spec/fixtures/expected_lease_options_client_class.txt"))
    end
  end

  context "when Windows 10 devices with delivery optimisation enabled send DHCP requests" do
    it "provides a lease with DHCP options from global options as well as an additional option: private option 234" do
      `perfdhcp -r 2 \
        -n 3 \
        -R 1 \
        -b mac=00:0c:01:02:03:04 \
        -d 2 \
        -4 \
        -o 55,00EA \
        -W 20000000 \
        172.1.0.10`
      sleep 5 
      expect(dhcp_offer_packet_content).to include(File.read("./spec/fixtures/expected_lease_options_delivery_optimised.txt"))
    end
  end
end
