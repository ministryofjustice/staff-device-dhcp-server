require_relative '../aws_client'

describe AwsClient do
  it 'chunks 20 metrics maximum' do
    metrics = []
    fake_client = spy
    21.times do |i|
      metrics << { metric_name: i.to_s, value: i }
    end

    described_class.new(client: fake_client, aws_config: { stub_responses: true }).put_metric_data(metrics)
    expect(fake_client).to have_received(:put_metric_data).twice
  end
end
