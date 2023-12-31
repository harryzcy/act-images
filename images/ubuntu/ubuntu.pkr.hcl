packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "1.0.8"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:22.04"
  commit = true
  changes = [
    "ENTRYPOINT [\"\"]",
    "CMD [\"/bin/bash\"]"
  ]
}

build {
  name = "ubuntu"
  sources = [
    "source.docker.ubuntu"
  ]

  post-processor "docker-tag" {
    repository = "ubuntu"
    tags       = ["22.04", "latest"]
  }
}
