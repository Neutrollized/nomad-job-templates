job "jira" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "jira" {
    count = 1

    update {
      max_parallel = 1
    }

    task "jira" {
      driver = "docker"

      # https://hub.docker.com/r/atlassian/jira-software
      env {
        ATL_TOMCAT_SECURE="true"
        ATL_TOMCAT_SCHEME="https"
        ATL_PROXY_NAME="${URL}"
        ATL_PROXY_PORT="443"
      }

      config {
        image = "atlassian/jira-software:8.5.4"

        port_map {
          http = 8080
        }
        port_map {
          https = 8443
        }
      }

      resources {
        cpu = 500
        memory = 2048
        network {
          port "http" {}
          port "https" {}
        }
      }

      service {
        name = "jira"
        tags = ["jira", "8.5.4", "urlprefix-${URL}/"]
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
