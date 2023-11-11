packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "basic-example" {
  profile       = "terraform_user"
  region        = "${var.region}"
  instance_type = "${var.instance_type}"
  ami_name      = "golden_image-{{timestamp}}"
  ssh_username  = "ubuntu"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20231025"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
}

build {
  sources = [
    "source.amazon-ebs.basic-example"
  ]
}