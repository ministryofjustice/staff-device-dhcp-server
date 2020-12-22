# Kea High Availability

Kea does not support cloud native elastic scaling. The documented, [supported configurations](https://kea.readthedocs.io/en/latest/arm/hooks.html#supported-configurations), are hot-standby, load-balancing and passive backup.

Kea is configured to run in [hot-standby mode](https://kea.readthedocs.io/en/kea-1.8.1/arm/hooks.html#hot-standby-configuration) in conjunction with a [AWS RDS](https://aws.amazon.com/rds/) MySQL shared lease database. See [Discounted Configurations](#discounted-configurations) for more information.

![architecture](images/kea-ha.png)
[Image Source](images/kea-ha.drawio)

## Hot Standby

The hot standby configuration mandates a two server architecture containing a __primary__ and __secondary__ server. The primary server handles DHCP traffic while the secondary silently ignores requests.

In this architecture, both servers are provided with identical configuration files, except for the `this-server-name` attribute, identifying the primary and secondary roles of instances.

In the event the primary server becomes unavailable, the secondary is configured to automatically assume the primary role and handle DHCP traffic.

The instances are linked via a known management communication channel. Each servers' communication channel is routed via it's dedicated load balancer meaning that servers can be restarted or replaced while maintaining a consistent control channel address.

Server instances are provisioned using [AWS Fargate](https://aws.amazon.com/fargate/) to benefit from existing capabilities such as container deployment and health monitoring. Scalability is achieved by editing the terraform `aws_ecs_task_definition` (defined in the [infrastructure repository](https://github.com/ministryofjustice/staff-device-dns-dhcp-infrastructure)) then running the deployment pipeline. Initial experiments indicate that these scaling operations, using Fargate capabilities, are minimal impact.

## Shared Lease Database

Irrespective of the selected load balancing strategy, lease information needs to be persisted across server deployments and restarts. An in-memory implementation is potentially slower during (re)starts as it requires the Kea servers to synch before coming online and requires that at least one server is always running.

The [Kea documentation](https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/High-Availability-Design#central-lease-database) details that the lease synch step is skipped, meaning servers come online faster:
> *... When one of the servers (primary, standby, or load balancing) comes back online after a failure, it follows similar procedure to enable the DHCP service as described in previous sections, except that it doesn't synchronize the lease database with the peers. It transitions directly to the ''ready'' state (bypassing ''syncing'' state). ...*

The lease database will be implemented using AWS RDS to reduce management overhead, using built in RDS backup functionality.


## Discounted Configurations

### Load Balancing Configuration

The load balancing configuration requires subnet pools are specified and divided, in the configuration file, using client classes. This significantly increases the complexity of the configuration file and would not scale elastically. For example, on a scale in event, the configuration would need to be recalculated to divide scopes between the remaining servers. The configuration would then need to be redeployed to the live severs. Additionally client-class functionally is already required for the MoJ implementation.

### Passive Backup Configuration

The passive backup configuration was discounted on the grounds that leases will be stored in AWS RDS database, providing a low management and robust lease data storage solution.

From the [Kea documentation](https://kea.readthedocs.io/en/latest/arm/hooks.html#supported-configurations):
> *... The passive-backup configuration is used in situations when an administrator wants to take advantage of the backup servers as an additional storage for leases without a need for running the fully blown failover setup. In this case, if the primary server fails, the DHCP service is lost and it requires that the administrator manually starts the primary to resume the DHCP service. ...*

## References

- [Kea High Availability vs ISC DHCP Failover](https://kb.isc.org/docs/aa-01617) (Retrieved December 22, 2020)
- [Kea 1.4 Adds High-Availability Mode](https://www.isc.org/blogs/kea-1-4-adds-high-availability-mode/) (Retrieved December 22, 2020)
- [High Availability in Kea 1.4.0 - Design](https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/High-Availability-Design) (Retrieved December 22, 2020)
- [Kea documentation. 16.15. ha: High Availability](https://kea.readthedocs.io/en/kea-1.8.1/arm/hooks.html#high-availability-library) (Retrieved December 22, 2020)
