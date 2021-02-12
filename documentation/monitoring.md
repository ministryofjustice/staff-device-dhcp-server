# Monitoring

Metrics for the Kea servers are displayed in the [IMA Grafana dashboard](https://github.com/ministryofjustice/staff-infrastructure-monitoring-config/blob/main/integrations/staff-device-dns-dhcp-infrastructure/dashboards/dhcp/dhcp_template.json).
The JSON configuration file for the dashboard is stored in this repo, when updates are made, the JSON needs to be saved and tracked with version control.

The metrics categories are:

- AWS Service metrics
- Kea Network metrics
- Kea Subnet metrics

![Grafana Dashboard](/documentation/images/dashboard.png)
