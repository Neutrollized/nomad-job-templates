job "redis" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "redis" {
    count = 1

    update {
      max_parallel = 1
    }

    network {
      port "db" { to = 6379 }
    }

    task "redis" {
      driver = "docker"

      config {
        # https://hub.docker.com/_/redis
        image = "redis:6.0.4-alpine"

        ports = ["db"]
      }

      resources {
        cpu = 100
        memory = 256
      }

      # https://www.nomadproject.io/docs/job-specification/service/#address_mode
      service {
        name = "redis"
        tags = ["redis", "6.0.4"]
        address_mode = "driver"
        port = "db"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
