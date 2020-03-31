# RabbitMQ-HA for Nomad
We can't use dynamic ports with RabbitMQ-HA as all the ports in a cluster must use the same port.  Luckily, you can configure all of these with [RabbitMQ Environment Variables](https://www.rabbitmq.com/configure.html#supported-environment-variables):
- EPMD port: `ERL_EPMD_PORT`
- AMQP port: `RABBITMQ_NODE_PORT` and `cluster_formation.consul.svc_port` in `rabbitmq.conf`
- Clustering port (used for inter-node communication): `RABBITMQ_DIST_PORT`
If you do decide to use non-standard ports, you'll also have to adjust the [`port_map`](https://nomadproject.io/docs/drivers/docker/#forwarding-and-exposing-ports) parameter in your job config as well as network ports under `resources`.

### NOTES + mini rant
Some stuff is weird -- you can't set the `EPMD_PORT` or the `RABBITMQ_DIST_PORT` from the `rabbitmq.conf`, and you can't set the UI port as an ENV variable, and can only be set from within the `rabbitmq.conf` file (if you must know, it's `management.tcp.port` -- it doesn't even have "ui" in its name!! C'mon, RabbitMQ get your shit together!!).  As a result, if you do use non-standard ports, you'll have to modify both ENV and config file values.

## References
- [RabbitMQ Clustering Guide](https://www.rabbitmq.com/clustering.html)
- [Pondidum's Nomad-RabbitMQ-Demo](https://github.com/Pondidum/Nomad-RabbitMQ-Demo)
