job "rabbitmq-ha" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "cluster" {
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

    task "rabbitmq-ha" {
      driver = "docker"

      # https://www.rabbitmq.com/clustering.html#erlang-cookie
      # in prod, your Erlang Cookie should be a secret pulled from Vault
      env {
        ERL_EPMD_PORT = "4369"
        RABBITMQ_DIST_PORT = "25672"
        RABBITMQ_ERLANG_COOKIE = "whitemacadamianut"
      }

      # /etc/rabbitmq/enabled_plugins
      template {
        data = <<EOH
[rabbitmq_management,rabbitmq_peer_discovery_consul].
EOH

        destination = "local/enabled_plugins"
      }

      # see https://github.com/rabbitmq/rabbitmq-server/blob/master/docs/rabbitmq.conf.example for full config file
      # total_memory_available_override_value should match your resources memory value
      # /etc/rabbitmq/rabbitmq.conf
      template {
        data = <<EOH
listeners.tcp.default = 5672
loopback_users.guest = false
management.tcp.port = 15672
default_user = administrator
default_pass = password
cluster_formation.consul.svc = rabbitmq-ha
cluster_formation.consul.svc_port = 5672
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
        port_map {
          epmd = 4369
          amqp = 5672
          ui = 15672
          clustering = 25672
        }

        volumes = [
          "local/enabled_plugins:/etc/rabbitmq/enabled_plugins",
          "local/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf"
        ]
      }

      resources {
        cpu = 100
        memory = 256
        network {
          mbits = 30
          port "epmd" {
            static = 4369
          }
          port "amqp" {
            static = 5672
          }
          port "ui" {
            static = 15672
          }
          port "clustering" {
            static = 25672
          }
        }
      }

      service {
        name = "rabbitmq-ha"
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
