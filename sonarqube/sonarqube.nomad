job "sonarqube" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "sonarqube" {
    count = 1

    update {
      max_parallel = 1
    }

    network {
      port "http" { to = 9000 }
    }

    task "sonarqube" {
      driver = "docker"

      # https://docs.sonarqube.org/latest/setup/get-started-2-minutes/
      env {
        SONAR_ES_BOOTSTRAP_CHECKS_DISABLE = "true"
      }

      config {
        image = "sonarqube:8.5.0-community"

        ports = ["http"]
      }

      resources {
        cpu = 500
        memory = 4096
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
