job "jira" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "jira" {
    count = 1

    update {
      max_parallel = 1
    }

    network {
      port "http" { to = 8080 }
      port "https" { to = 8443 }
    }

    task "jira" {
      driver = "docker"

      # https://hub.docker.com/r/atlassian/jira-software
      env {
        ATL_TOMCAT_PORT="8080"
        ATL_TOMCAT_REDIRECTPORT="8443"
        ATL_TOMCAT_SECURE="true"
        ATL_TOMCAT_SCHEME="https"
        ATL_PROXY_NAME="${URL}"
        ATL_PROXY_PORT="443"
      }

      config {
        image = "atlassian/jira-software:8.5.4"

        ports = ["http", "https"]
      }

      resources {
        cpu = 500
        memory = 2048
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
