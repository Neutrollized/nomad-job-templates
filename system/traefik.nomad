job "traefik" {
  datacenters = ["${DC_NAME}"]
  type = "system"

  group "traefik" {
    network {
      port "lb" { static = 8080 }
    }

    task "traefik" {
      driver = "docker"
      config {
        # https://hub.docker.com/_/traefik
        image = "traefik:v2.4.8"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml"
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":8080"
        [entryPoints.http.forwardedHeaders]
        trustedIPs = ["${EXT LB IP1}", "${EXT_LB_IP2}"]

# enable Consul Catalog configuration backend
[providers.consulCatalog]
    prefix = "traefik"
    exposedByDefault = false
    
    [providers.consulCatalog.endpoint]
        address = "127.0.0.1:8500"
        scheme = "http"

# if you use the Consul K/V
# https://doc.traefik.io/traefik/providers/consul/
#[providers.consul]
#    rootKey = "traefik"
#    endpoints = ["127.0.0.1:8500"]
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128	#256 for prod
      }
    }

    service {
      name = "traefik"
      check {
        port = "lb"
        name = "alive"
        type = "tcp"
        interval = "10s"
        timeout = "2s"
      }
    }

  }
}
