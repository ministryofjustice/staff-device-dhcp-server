# DHCP Docker Image

This folder contains the dockerfile to create the [ISC Kea](https://www.isc.org/kea/) DHCP server docker image.

This images is pushed up to [Amazon ECR](https://aws.amazon.com/ecr/).

## Getting started

To get started with development you will need:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### Running locally

See the target `run_development_environment` in the [Makefile](./Makefile)

### Deploying to production

Deployments are automated in the CI pipeline. See [buildspec.yml](./buildspec.yml)

## ISC Kea versions

At the time of writing, the stable release for ISC Kea is [version 1.6](https://cloudsmith.io/~isc/repos/kea-1-6/packages/).

There is a [1.7 release](https://cloudsmith.io/~isc/repos/kea-1-7/packages/), but it is a development release which is not ready for use in production applications.

For the reasons above, we have elected to use Kea version 1.6.

## TODO

- Add a note about the following warning messages when making for dev (ignore them):
  - `Warning: apt-key output should not be parsed (stdout is not a terminal)`
  - `debconf: delaying package configuration, since apt-utils is not installed`
- Add a note on testing locally using nmap
- Add note on killing docker images with `docker-compose down -v` when you are done

## NMAP

- Run `ifconfig`, choose each name from to bottom
- If it gives you `br-c8ec119ba6dc`, run: `sudo nmap --script broadcast-dhcp-discover -e br-c8ec119ba6dc`
