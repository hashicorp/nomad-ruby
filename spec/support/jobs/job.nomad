job "job" {
  type = "service"

  region      = "global"
  datacenters = ["dc1"]

  priority = 50

  all_at_once = true

  meta {
    "foo" = "bar"
  }

  group "group" {
    count = "3"

    meta {
      "zip" = "zap"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    ephemeral_disk {
      size = 10
    }

    task "task" {
      meta {
        "zane" = "willow"
      }

      env {
        "key" = "value"
      }

      driver = "raw_exec"

      config {
        command = "/bin/sleep"
        args    = ["1000"]
      }

      artifact {
        source = "https://github.com/hashicorp/http-echo/releases/download/v0.2.3/http-echo_0.2.3_SHA256SUMS"

        options {
          checksum = "md5:d2267250309a62b032b2b43312c81fec"
        }
      }

      logs {
        max_files     = 1
        max_file_size = 2
      }

      resources {
        cpu    = 20
        memory = 12

        network {
          mbits = 1

          port "db" {}
          port "http"{}
        }
      }

      service {
        name = "service-1"
        tags = ["tag1"]
        port = "db"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        check {
          name     = "still-alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "service-2"
        port = "db"
      }

      template {
        data          = "key: {{ key \"service/my-key\" }}"
        destination   = "local/file-1.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        source        = "local/http-echo_0.2.3_SHA256SUMS"
        destination   = "local/file-2.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      kill_timeout = "250ms"
    }
  }
}
