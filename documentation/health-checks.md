# Container Health Checks

To ensure that an invalid task / container does not get into the production ECS cluster, a bootstrap script has been written. This uses `perfdhcp` to ensure that an IP can be leased. If this fails, a notification will be sent to the SNS critical notification topic and forwarded to subscribers. This check is not performed locally.
