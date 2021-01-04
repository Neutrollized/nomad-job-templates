job "fabio" {
  datacenters = ["${DC_NAME}"]
  type = "system"

  group "fabio" {
    network {
      port "ui" { static = 9998 }
      port "lb" { static = 9999 }
    }

    task "fabio" {
      driver = "docker"
      config {
        # https://hub.docker.com/r/fabiolb/fabio/tags
        image = "fabiolb/fabio:1.5.13-go1.13.4"
        network_mode = "host"
      }

      resources {
        cpu    = 200
        memory = 128	#256 for prod
      }
    }
  }
}
