# KEA DHCP High Availability Testing

This document details the results of the Kea HA testing, carried out on the 8th of February 2021.

## Configuration

- [Kea DHCP V1.8.2](https://github.com/ministryofjustice/staff-device-dhcp-server/blob/main/dhcp-service/Dockerfile) was the subject under test.
- Hosted on [AWS Fargate](https://aws.amazon.com/fargate/) with 4GB Memory and 1GB CPU available
- The load testing tool is [perfdhcp](#PerfDHCP).
- Multi-Threading is enabled, the server can concurrently process 12 concurrent threads with up to 65 queued packets per thread.
- High Availability is configured for Kea to run in [hot-standby mode](https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/High-Availability-Design), using a Primary and Standby server
- Kea is configured to use a shared AWS RDS MySQL lease backend. Sized at [db.t2.large](https://aws.amazon.com/rds/instance-types/)
- The production configuration file has been loaded and contains the following:
  - 142 Sites
  - 829 Subnets
  - 14404 reservations
  - At least two client classes per subnet

## Considerations

- Tests are run from a remote site in the Corsham DC, which is integrated through an AWS Transit Gateway to the DHCP service. This may introduce network latency
- A request is considered the entire DORA DHCP request exchange
- The Kea configuration file is checked, in an S3 bucket, every 5 minutes. It is compared to the current configuration and is loaded when changes are detected. This operation has no discernable impact on performance.
- The perfdhcp testing tool occasionally exits before the last response packet is delivered, skewing the results by 1. This does not affect the findings of this test and was taken into consideration.

## Test Command

[Perfdhcp version 1.8.1](https://kea.readthedocs.io/en/latest/man/perfdhcp.8.html) was used for performance testing.

The drop rate was manually observed to establish the health threshold.

The following command was run from the remote site in Corsham.

```sh
perfdhcp -4 $DHCP_SERVICE_IP -n3000 -r300 -R 5000000 -d3
```

The drop time is set to 3 seconds with the `-d` flag, any request taking more than 3 seconds is considered a failed request.
