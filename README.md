# DHCP Docker Image

This folder contains the dockerfile to create the [ISC Kea](https://www.isc.org/kea/) DHCP server docker image.

This images is pushed up to [Amazon ECR](https://aws.amazon.com/ecr/).

## Getting started

To get started with development you will need:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### Running locally

See the target `run` in the [Makefile](./Makefile)

### Deploying to production

Deployments are automated in the CI pipeline. See [buildspec.yml](./buildspec.yml)

## Manual Testing

- Run `ifconfig` to find the name for the docker-compose network interface.
- Run  
 `sudo nmap --script broadcast-dhcp-discover -e <NETWORK_INTERFACE>`
  - The dhcp server should respond with an offer. EG:
  
  ```bash
    Starting Nmap 7.80 ( https://nmap.org ) at 2020-07-28 14:53 BST
    Pre-scan script results:
    | broadcast-dhcp-discover: 
    |   Response 1 of 1: 
    |     IP Offered: 192.0.2.10
    |     DHCP Message Type: DHCPOFFER
    |     Subnet Mask: 255.255.255.0
    |     IP Address Lease Time: 1h06m40s
    |_    Server Identifier: 172.29.0.4
    WARNING: No targets were specified, so 0 hosts scanned.
    Nmap done: 0 IP addresses (0 hosts up) scanned in 0.53 seconds
  ```

## ISC Kea version

At the time of writing, the stable release for ISC Kea is [version 1.6](https://cloudsmith.io/~isc/repos/kea-1-6/packages/).
