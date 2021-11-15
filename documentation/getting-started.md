# Getting started

To get started with development you will need:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)


Copy the .env.example file to a new .env file
`cp .env.example .env`

Populate the missing value (SHARED_SERVICES_ACCOUNT_ID)

## Authenticating Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured with credentials for shared services, do the following to authenticate:

```bash
aws-vault exec <SHARED_SERVICES_VAULT_PROFILE_NAME> -- make authenticate-docker
```

Replace `<SHARED_SERVICES_VAULT_PROFILE_NAME>` with the profile name and ID of the shared services account configured in aws-vault.

## Running Locally

See the target `run` in the [Makefile](/Makefile)

## Automated Testing

To run the tests locally run

```bash
$ make test
```

This will first clear out any leases in the local database. `perfdhcp` is used to emulate a number of clients and multiple [DORA](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol#Operation) cycles. The number of created leases is checked to ensure the server is operating as expected. The [dhcp_test.sh](./dhcp_test.sh) script will exit with a non zero code if the expected number of leases were not created.

## Manual Testing

- Run `ifconfig` to find the name for the docker-compose network interface.
- Run
  `sudo nmap --script broadcast-dhcp-discover -e <NETWORK_INTERFACE>`

  - The DHCP server should respond with an offer, e.g:

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
