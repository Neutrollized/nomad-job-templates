# Redis for Nomad
Nothing too out of the ordinary here with what you might expect from Redis as a container as it runs quite decently even on default settings.

The only thing I need to draw your attention to is the [`address_mode`](https://www.nomadproject.io/docs/job-specification/service/#address_mode) in the `service` stanza.  If you don't specify it, it will default to auto, which will then pick an arbitrary high port to map to it.  This affects what Consul returns from a service discovery perspective.
