job "datadog" {
  datacenters = ["${DC_NAME}"]
  type = "system"

  group "datadog" {
    task "datadog" {
      driver = "docker"

      env {
        DD_API_KEY = "${DD_API_KEY}"
        DD_DOGSTATSD_NON_LOCAL_TRAFFIC = "true"
      }

      config {
        # https://hub.docker.com/r/datadog/agent/tags
        image = "datadog/agent:6.18.0"

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro",
          "/proc/:/host/proc/:ro",
          "/sys/fs/cgroup/:/host/sys/fs/cgroup:ro"
        ]

        port_map {
          statsd = 8125
        }
      }

      resources {
        cpu    = 150
        memory = 128	#256 for prod
        network {
          mbits = 1

          port "statsd" {
            static = 8125
          }
        }
      }
    }
  }
}
