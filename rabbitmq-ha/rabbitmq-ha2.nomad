# example job file of a second RabbitMQ cluster that can run in parallel 
# with the first one using non-standard ports (I basically +1000)
job "rabbitmq-ha2" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "cluster2" {
    count = 3

    update {
      max_parallel = 1
    }

    migrate {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "5s"
      healthy_deadline = "30s"
    }

    network {
      port "epmd" { static = 5396 }
      port "amqp" { static = 6672 }
      port "ui" { static = 16672 }
      port "clustering" { static = 26672 }
    }

    task "rabbitmq-ha2" {
      driver = "docker"

      env {
        ERL_EPMD_PORT = "5369"
        RABBITMQ_DIST_PORT = "26672"
        RABBITMQ_ERLANG_COOKIE = "mintchip"
      }

      # /etc/rabbitmq/enabled_plugins
      template {
        data = <<EOH
[rabbitmq_management,rabbitmq_peer_discovery_consul].
EOH

        destination = "local/enabled_plugins"
      }

      # /etc/rabbitmq/rabbitmq.conf
      template {
        data = <<EOH
listeners.tcp.default = 6672
loopback_users.guest = false
management.tcp.port = 16672
default_user = administrator
default_pass = password
cluster_formation.consul.svc = rabbitmq-ha2
cluster_formation.consul.svc_port = 6672
cluster_formation.consul.host = ${CONSUL_SERVER_IP}
cluster_formation.peer_discovery_backend = rabbit_peer_discovery_consul
cluster_formation.consul.svc_addr_auto = true
total_memory_available_override_value = 256MB
EOH

        destination = "local/rabbitmq.conf"
      }

      config {
        # https://hub.docker.com/_/rabbitmq
        image = "rabbitmq:3.8.2-management-alpine"

        # https://nomadproject.io/docs/runtime/interpolation/#node-variables
        # because each RabbitMQ node needs a unique name
        hostname = "${attr.unique.hostname}"

        # https://www.rabbitmq.com/clustering.html#ports
        ports = ["epmd", "amqp", "ui", "clustering"]

        volumes = [
          "local/enabled_plugins:/etc/rabbitmq/enabled_plugins",
          "local/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf"
        ]
      }

      resources {
        cpu = 100
        memory = 256
      }

      service {
        name = "rabbitmq-ha2"
        tags = ["rabbitmq", "3.8.2", "urlprefix-${URL}/"]
        port = "ui"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
