# Redis for Nomad
Nothing too out of the ordinary here with what you might expect from Redis as a container as it runs quite decently even on default settings.

The only thing I need to draw your attention to is the [`address_mode`](https://www.nomadproject.io/docs/job-specification/service/#address_mode) in the `service` stanza.  If you don't specify it, it will default to auto, which will then pick an arbitrary high port to map to it.  This affects what Consul returns from a service discovery perspective.

Wait!! How does that differ from setting a static port in the `resources` stanza like in the [Rabbit-MQ example](https://github.com/Neutrollized/nomad-job-templates/blob/master/rabbitmq-ha/rabbitmq-ha.nomad#L88)?  Let's look at some scenarios:

#### scenario 1
- dynamic network port in `resources` stanza
i.e. redis.service.consul --> [Nomad worker IP]:[some high port number]

#### scenario 3
- static network port (6379) in `resources` stanza
i.e. redis.service.consul --> [Nomad worker IP]:6379

#### scenario 3
- dynamic network port in `resources` stanza + `address_mode = "driver"`
i.e. redis.service.consul --> [Docker instance IP]:6379

At the end of the day, traffic all end up at your Redis instance running in Docker on port 6379, the `address_mode` simply changes what Consul returns when you query the SRV record for your service.

## ...might I suggest instead...
You give [KeyDB](https://keydb.dev/) a try.  It's a drop-in replacement Redis that's written in C++; config file is the same, directory structure is the same (just place `redis` with `keydb`) -- it's identical in every aspect, except faster.  Plus, it's made in Canada.
