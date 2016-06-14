job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "exec"
      config {
        command = "fabio"
      }

      artifact {
        source = "https://storage.googleapis.com/hashistack/fabio/v1.1.3/fabio"
        options {
          checksum = "sha256:7adc20402773d425a8e45b40cc29efc832172a152ea743f8eeefffa0fbbe6023"
        }
      }

      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 100

          port "http" {
            static = 9999
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
