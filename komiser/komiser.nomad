job "komiser" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "komiser" {
    count = 1

    update {
      max_parallel = 1
    }

    network {
      port "https" { to = 3000 }
    }

    task "komiser" {
      driver = "docker"

      # https://hub.docker.com/r/mlabouardy/komiser/tags
      env {
        AWS_ACCESS_KEY_ID = ''
        AWS_SECRET_ACCESS_KEY = ''
        AWS_DEFAULT_REGION = ''
      }

      config {
        image = "mlabouardy/komiser:2.4.0"

        ports = ["https"]
      }

      resources {
        cpu = 100
        memory = 512
      }

      service {
        name = "komiser"
        tags = ["komiser", "2.4.0", "urlprefix-${URL}/"]
        port = "https"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
