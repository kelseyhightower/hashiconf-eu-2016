job "hashiapp" {
  datacenters = ["dc1"]

  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "hashiapp" {
    count = 8

    task "hashiapp" {
      driver = "exec"
      config {
        command = "hashiapp"
      }

      artifact {
        source = "https://storage.googleapis.com/hightowerlabs/hashiapp"
        options {
          checksum = "sha256:b455f911778403d53b525e9f72e39fa47120030393ef2a78a9f4510084215af1"
        }
      }

      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 100
          port "http" {}
        }
      }

      service {
        name = "hashiapp"
        tags = ["hashiapp"]
        port = "http"
        check {
          type = "http"
          name = "healthz"
          interval = 15
          timeout = 3
          path = "/healthz"
        }
      }
    }
  }
}
