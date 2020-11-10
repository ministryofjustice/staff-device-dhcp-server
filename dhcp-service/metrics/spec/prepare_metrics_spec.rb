require 'rspec'
require 'json'
require_relative '../prepare_metric'

describe PrepareMetric do
  let(:client) { spy }
  let(:kea_stats) { [] }

  it 'raises an error if the kea stats is empty' do
    expect { described_class.new(client: client).execute(kea_stats: kea_stats) }.to  raise_error('Kea stats are empty')
  end

  it 'converts kea stats to cloudwatch metrics' do
    kea_stats = JSON.parse(File.read("./stats/spec/payload.json"))
    result = described_class.new(client: client).execute(kea_stats: kea_stats)

    expected_result = [
      {
        metric_name: "cumulative-assigned-addresses",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "declined-addresses",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-ack-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-ack-sent",
        timestamp: 1604921619,
        value: 18
      }, {
        metric_name: "pkt4-decline-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-discover-received",
        timestamp: 1604921619,
        value: 19
      }, {
        metric_name: "pkt4-inform-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-nak-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-nak-sent",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-offer-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-offer-sent",
        timestamp: 1604921619,
        value: 19
      }, {
        metric_name: "pkt4-parse-failed",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-receive-drop",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-received",
        timestamp: 1604921619,
        value: 37
      }, {
        metric_name: "pkt4-release-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "pkt4-request-received",
        timestamp: 1604921619,
        value: 18
      }, {
        metric_name: "pkt4-sent",
        timestamp: 1604921619,
        value: 37
      }, {
        metric_name: "pkt4-unknown-received",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "reclaimed-declined-addresses",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "reclaimed-leases",
        timestamp: 1604921609,
        value: 0
      }, {
        metric_name: "cumulative-assigned-addresses",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1018"
          }
        ]
      }, {
        metric_name: "declined-addresses",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1018"
          }
        ]
      }, {
        metric_name: "reclaimed-declined-addresses",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1018"
          }
        ]
      }, {
        metric_name: "reclaimed-leases",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1018"
          }
        ]
      }, {
        metric_name: "total-addresses",
        timestamp: 1604921609,
        value: 255,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1018"
          }
        ]
      }, {
        metric_name: "assigned-addresses",
        timestamp: 1604921609,
        value: 10,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1"
          }
        ]
      }, {
        metric_name: "cumulative-assigned-addresses",
        timestamp: 1604921609,
        value: 0,
        dimensions:
          [
            {
              name: "Subnet",
              value: "1"
            }
          ]
      }, {
        metric_name: "declined-addresses",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1"
          }
        ]
      }, {
        metric_name: "reclaimed-declined-addresses",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1"
          }
        ]
      }, {
        metric_name: "reclaimed-leases",
        timestamp: 1604921609,
        value: 0,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1"
          }
        ]
      }, {
        metric_name: "total-addresses",
        timestamp: 1604921609,
        value: 512,
        dimensions:
        [
          {
            name: "Subnet",
            value: "1"
          }
        ]
      }
    ]

    expect(result).to eq(expected_result)
  end

  it 'calls the client with the correct arguments' do
    client = spy
    kea_stats = [ { "arguments" => [] } ]
    described_class.new(client: client).execute(kea_stats: kea_stats)

    expect(client).to have_received(:put_metric_data).with([])
  end
end
