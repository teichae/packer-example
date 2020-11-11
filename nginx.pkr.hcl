variable "dockerhub_username" {
  type    = string
  default = "teichae"
}

variable "dockerhub_password" {
  type    = string
  default = "password"
}

source "docker" "docker" {
  changes = ["VOLUME /data", "WORKDIR /data", "EXPOSE 80", "ENTRYPOINT [\"docker-entrypoint.sh\"]"]
  commit  = true
  image   = "ubuntu:18.04"
}

build {
  sources = ["source.docker.docker"]

  provisioner "ansible" {
    playbook_file = "provision.yml"
    user          = "root"
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "teichae/packer-nginx"
      tags       = ["latest"]
    }
    post-processor "docker-push" {
      login          = "true"
      login_username = "${var.dockerhub_username}"
      login_password = "${var.dockerhub_password}"
    }
  }
}