variable "owner" {}
variable "env" {}
variable "region" {}

variable "instance_type" {
  default = "t2.nano"
}
variable "ingress_cidr" {}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["379101102735"] # Debian Project
}

data "template_file" "user-data" {
  template = <<EOF
#cloud-config
packages:
- git
runcmd:
  - 'apt update'
  - 'apt install curl htop ncdu vim'
EOF
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.owner}-${var.env}-${var.region}-tfstate"
    key = "001-vpc.tfstate"
    region = "${var.region}"
  }
}
