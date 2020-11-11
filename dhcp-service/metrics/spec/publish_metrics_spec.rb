require 'rspec'
require 'json'
require 'timecop'
require 'time'
require_relative '../publish_metrics'

describe PublishMetrics do
  let(:client) { spy }
  let(:kea_stats) { [] }
  let(:time) { DateTime.now.to_time }
  let(:timestamp) { time.to_i }

  before do
    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end

  it 'raises an error if the kea stats is empty' do
    expect { described_class.new(client: client).execute(kea_stats: kea_stats) }.to raise_error('Kea stats are empty')
  end

  it 'converts kea stats to cloudwatch metrics and calls the client to publish them' do
    kea_stats = JSON.parse(File.read("./metrics/spec/kea_api_stats_response.json"))
    result = described_class.new(client: client).execute(kea_stats: kea_stats)

    expected_result = [
      {
        metric_name: "cumulative-assigned-addresses",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "declined-addresses",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-ack-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-ack-sent",
        timestamp: timestamp,
        value: 18
      }, {
        metric_name: "pkt4-decline-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-discover-received",
        timestamp: timestamp,
        value: 19
      }, {
        metric_name: "pkt4-inform-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-nak-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-nak-sent",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-offer-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-offer-sent",
        timestamp: timestamp,
        value: 19
      }, {
        metric_name: "pkt4-parse-failed",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-receive-drop",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-received",
        timestamp: timestamp,
        value: 37
      }, {
        metric_name: "pkt4-release-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "pkt4-request-received",
        timestamp: timestamp,
        value: 18
      }, {
        metric_name: "pkt4-sent",
        timestamp: timestamp,
        value: 37
      }, {
        metric_name: "pkt4-unknown-received",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "reclaimed-declined-addresses",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "reclaimed-leases",
        timestamp: timestamp,
        value: 0
      }, {
        metric_name: "cumulative-assigned-addresses",
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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
        timestamp: timestamp,
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

    expect(client).to have_received(:put_metric_data).with(expected_result)
  end
end
