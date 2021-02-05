job "datadog" {
  datacenters = ["${DC_NAME}"]
  type = "system"

  group "datadog" {
    network {
      port "statsd" { static = 8125 }
    }

    task "datadog" {
      driver = "docker"

      env {
        DD_API_KEY = "[DATADOG API KEY GOES HERE]"
        DD_DOGSTATSD_NON_LOCAL_TRAFFIC = "true"
        DD_PROCESS_AGENT_ENABLED = "true"
        DD_LOGS_ENABLED = "true"
        DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL = "true"
        DD_AC_EXCLUDE = "name:datadog"
      }

      config {
        # https://hub.docker.com/r/datadog/agent/tags
        image = "datadog/agent:7.25.1"

        # IMPORTANT: requires docker volumes to be enabled in the Nomad client config
        # https://www.nomadproject.io/docs/drivers/docker#enabled-1
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro",
          "/proc/:/host/proc/:ro",
          "/sys/fs/cgroup/:/host/sys/fs/cgroup:ro",
          "/etc/passwd:/etc/passwd:ro",
          "/opt/datadog-agent/run:/opt/datadog-agent/run:rw"
        ]

        ports = ["statsd"]
      }

      resources {
        cpu    = 150
        memory = 128	#256 for prod
      }
    }
  }
}
