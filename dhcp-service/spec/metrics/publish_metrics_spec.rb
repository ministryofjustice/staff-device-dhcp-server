require_relative '../spec_helper'
require_relative '../../metrics/publish_metrics'

describe PublishMetrics do
  let(:client) { spy }
  let(:kea_stats) { [] }
  let!(:time) { DateTime.now.to_time }
  let!(:timestamp) { time.to_i }

  let(:subject) do
    described_class.new(client: client)
  end

  let(:kea_client) do
    double(get_config: JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_config_get_response.json")))
  end

  before do
    Timecop.freeze(time)
    ENV.delete("SERVER_NAME")
  end

  after do
    Timecop.return
  end

  it 'raises an error if the kea stats is empty' do
    expect { subject.execute(kea_stats: kea_stats) }.to raise_error('Kea stats are empty')
  end

  it 'raises an error if the server name is not set' do
    kea_stats = JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_stats_response.json"))

    expect { subject.execute(kea_stats: kea_stats) }.to raise_error(KeyError)
  end

  it 'does not publish when the metrics payload does not contain the "arguments" key' do
    subject.execute(kea_stats: [{}])

    expect(client).to_not have_received(:put_metric_data)
  end

  context 'Primary Server' do
    before do
      ENV['SERVER_NAME'] = "primary"
    end

    it 'converts kea stats to cloudwatch metrics and calls the client to publish them' do
      kea_stats = JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_stats_response.json"))
      subject.execute(kea_stats: kea_stats)

      expected_result = [
      {
          metric_name: "cumulative-assigned-addresses",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "declined-addresses",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-ack-received",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-ack-sent",
          timestamp: timestamp,
          value: 18,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-decline-received",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-discover-received",
          timestamp: timestamp,
          value: 19,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-nak-received",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-nak-sent",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-offer-received",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-offer-sent",
          timestamp: timestamp,
          value: 19,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-receive-drop",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-release-received",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-request-received",
          timestamp: timestamp,
          value: 18,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "pkt4-unknown-received",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "reclaimed-declined-addresses",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        }, {
          metric_name: "reclaimed-leases",
          timestamp: timestamp,
          value: 0,
          dimensions: [
            {
              name: "Server",
              value: "primary"
            }
          ]
        } 
      ]

      expect(client).to have_received(:put_metric_data).with(expected_result)
    end
  end

  context 'Standby Server' do
    before do
      ENV['SERVER_NAME'] = 'standby'
    end

    it 'sets the Server dimension to standby' do
      kea_stats = JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/kea_api_stats_response.json"))
      expected_result = {
        metric_name: "reclaimed-leases",
        timestamp: timestamp,
        value: 0,
        dimensions: [
          {
            name: "Server",
            value: "standby"
          }
        ]
      } 

      subject.execute(kea_stats: kea_stats)
      expect(client).to have_received(:put_metric_data).with(a_hash_including(expected_result))
    end
  end
end
