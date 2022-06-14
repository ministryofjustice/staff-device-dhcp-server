require_relative "spec_helper"
require_relative "../metrics/db_client"
require 'sequel'

describe "getting leases" do
  let! (:db_client) { DbClient.new.db }

  before do
    db_client[:lease4].truncate
    db_client.disconnect
    Process.fork { `tshark -iany -f 'ip src 172.1.0.10 and udp port 67' -w ./leases.pcap -q -a packets:1` }
  end

  it "can obtain 10 leases" do
    `perfdhcp -r 2 \
      -n 10 \
      -R 10 \
      -d 2 \
      -4 \
      -o 55,00EA \
      -W 20000000 \
      172.1.0.10`

    expect(db_client[:lease4].count).to eq(10)
    db_client.disconnect
  end
end
