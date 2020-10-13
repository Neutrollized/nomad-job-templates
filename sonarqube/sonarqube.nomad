job "sonarqube" {
  datacenters = ["${DC}"]
  type = "service"

  group "sonarqube" {
    count = 1

    update {
      max_parallel = 1
    }

    task "sonarqube" {
      driver = "docker"

      # https://docs.sonarqube.org/latest/setup/get-started-2-minutes/
      env {
        SONAR_ES_BOOTSTRAP_CHECKS_DISABLE = "true"
      }

      config {
        image = "sonarqube:8.5.0-community"

        port_map {
          http = 9000
        }
      }

      resources {
        cpu = 500
        memory = 4096
        network {
          port "http" {}
        }
      }

      service {
        name = "sonarqube"
        tags = ["sonarqube", "8.5.0", "urlprefix-${URL}/"]
        port = "http"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
