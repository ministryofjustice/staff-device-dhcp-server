# Overview

This repository contains the Dockerfile to create the [ISC Kea](https://www.isc.org/kea/) DHCP server docker image. The configuration for this server is managed in the [Admin Portal](https://github.com/ministryofjustice/staff-device-dns-dhcp-admin).

The image is published to [Amazon ECR](https://aws.amazon.com/ecr/).

## ISC Kea version

At the time of writing, the stable release for ISC Kea is [version 1.8.x](https://cloudsmith.io/~isc/repos/kea-1-8/packages/).

## Documentation

- [Getting Started](/documentation/getting-started.md)
- [High Availability Configuration](/documentation/high-availability.md)
- [High Availability Testing](/documentation/high-availability-testing.md)
- [Performance Testing](/documentation/performance-metrics.md)
- [Health Checks](/documentation/health-checks.md)
- [Monitoring](/documentation/monitoring.md)
- [Deployment](/documentation/deployment.md)

## Notes

Kea currently does not support connecting to the database over SSL. See [kea#15](https://github.com/isc-projects/kea/pull/15)
