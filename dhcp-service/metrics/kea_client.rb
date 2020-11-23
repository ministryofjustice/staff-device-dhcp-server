class KeaClient
  def initialize
    uri = URI.parse("http://localhost:8000/")

    @req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
    @http = Net::HTTP.new(uri.host, uri.port)
  end

  def get_leases
    @req.body = { command: "stat-lease4-get", service: ["dhcp4"] }.to_json
    result = JSON.parse(@http.request(@req).body)
  end

  def get_statistics
    @req.body = { command: "statistic-get-all", service: ["dhcp4"] }.to_json
    JSON.parse(@http.request(@req).body)
  end

  def get_config
    @req.body = { command: "config-get", service: ["dhcp4"] }.to_json
    JSON.parse(@http.request(@req).body)
  end
end
