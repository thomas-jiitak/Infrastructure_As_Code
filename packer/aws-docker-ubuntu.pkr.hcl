packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  ami_name        = "CIS-HARDENED-UBUNTU-22.04-{{timestamp}}"
  ami_description = "CIS Hardened Ubuntu 22.04"
  instance_type   = "t2.micro"
  region          = var.region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/docker_playbook.yml"
    #galaxy_file = "requirements.yml"
  }
}